#!/usr/bin/env python3
"""Extract RoboCal test readings and limits into ML-style CSV reports."""

from __future__ import annotations

import argparse
import csv
import json
import math
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Sequence


DEFAULT_HEADERS = ["Test Name", "Reading", "Minimum Spec", "Maximum Spec"]
HEADER_ALIASES = {
    "name": {"testname", "test", "name", "metric", "item"},
    "reading": {"reading", "measured", "measuredvalue", "value", "result"},
    "minimum": {"minimumspec", "minspec", "minimum", "min", "lowerlimit", "lowerbound", "lsl"},
    "maximum": {"maximumspec", "maxspec", "maximum", "max", "upperlimit", "upperbound", "usl"},
}
NUMBER = r"[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?"
AUTO_EXPOSURE_RE = re.compile(
    rf"measured intensity\s+(?P<reading>{NUMBER}).*?acceptance range\s*"
    rf"\(\s*(?P<minimum>{NUMBER}|None)\s*,\s*(?P<maximum>{NUMBER}|None)\s*\)",
    re.IGNORECASE,
)
XYZ_RE = re.compile(
    rf"\[(?P<asset>blue|green|macbeth04|macbeth10|macbeth12|macbeth23|red|white)\]"
    rf"\s+capture:\s+XYZ_Illuminance\("
    rf"(?P<x>{NUMBER}),\s*(?P<y>{NUMBER}),\s*(?P<z>{NUMBER})\)",
    re.IGNORECASE,
)
NORMALIZATION_RE = re.compile(rf"Normalization factor:\s*(?P<value>{NUMBER})", re.IGNORECASE)
SOLVER_FINAL_RE = re.compile(rf"^Final\s+(?P<value>{NUMBER})\s*$", re.IGNORECASE)
HARDWARE_AVERAGING_RE = re.compile(rf"Hardware averaging factor of\s+(?P<value>{NUMBER})", re.IGNORECASE)


@dataclass(frozen=True)
class TestResult:
    name: str
    reading: str
    minimum: str = ""
    maximum: str = ""


def normalize_header(value: str) -> str:
    return re.sub(r"[^a-z0-9]", "", value.strip().lower())


def find_column(headers: Sequence[str], field: str) -> int | None:
    aliases = HEADER_ALIASES[field]
    return next((index for index, header in enumerate(headers) if normalize_header(header) in aliases), None)


def format_value(value: str) -> str:
    value = value.strip()
    return "" if value.lower() in {"none", "null", "nan"} else value


def discover_runs(root: Path) -> list[str]:
    run_ids = {path.parent.parent.name for path in root.glob("DGC/*/nominal_workflow_calibration/calibration_specs.yaml")}
    run_ids.update(path.parent.name for path in root.glob("DCC/*/dcc_config.json"))
    run_ids.update(match.group(1) for path in root.glob("log_file_*.log") if (match := re.search(r"(\d{8}_\d{6})", path.name)))
    return sorted(run_ids)


def resolve_post_process_root(path: Path) -> Path:
    post_process = path / "PostProcess"
    return post_process if post_process.is_dir() else path


def resolve_dgc_limits_path(station_config: Path | None, robocal_root: Path | None) -> Path | None:
    if not station_config or not station_config.exists() or not robocal_root:
        return None
    config_text = station_config.read_text(encoding="utf-8", errors="replace")
    dgc_section = re.search(r"^DGC:\s*$\n(?P<body>(?:^[ \t]+.*(?:\n|$))*)", config_text, re.MULTILINE)
    if not dgc_section:
        return None
    recipe_match = re.search(r"^\s+default_recipe:\s*['\"]?(?P<path>[^'\"\r\n]+)", dgc_section.group("body"), re.MULTILINE)
    if not recipe_match:
        return None
    recipe_path = robocal_root / "dgcc_standalone_station" / "config" / recipe_match.group("path").strip()
    if not recipe_path.exists():
        return None
    recipe_text = recipe_path.read_text(encoding="utf-8", errors="replace")
    limits_match = re.search(
        r"^DISPLAY_SPEC_LIMITS_FILE_PATH:\s*['\"]?(?P<path>[^'\"\r\n]+)", recipe_text, re.MULTILINE
    )
    if not limits_match:
        return None
    limits_path = robocal_root / "dgcc_standalone_station" / "config" / limits_match.group("path").strip()
    return limits_path if limits_path.exists() else None


def parse_dgc_limits(path: Path) -> dict[str, tuple[str, str]]:
    limits: dict[str, tuple[str, str]] = {}
    keys: list[tuple[int, str]] = []
    values: dict[str, dict[str, str]] = {}
    for raw_line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        match = re.match(r"^(?P<indent>\s*)(?P<key>[A-Za-z0-9_-]+):(?:\s*(?P<value>.*))?$", raw_line)
        if not match:
            continue
        indent = len(match.group("indent"))
        while keys and keys[-1][0] >= indent:
            keys.pop()
        key = match.group("key")
        value = (match.group("value") or "").strip(" '\"")
        if key in {"min", "max"} and value:
            metric = ".".join(item[1] for item in keys[1:])
            values.setdefault(metric, {})[key] = value
        else:
            keys.append((indent, key))
    for metric, bounds in values.items():
        limits[metric] = (bounds.get("min", ""), bounds.get("max", ""))
    return limits


def dgc_limit_key(column: str) -> str | None:
    match = re.match(r"(?P<color>blue|green|red)_right_(?P<metric>.+)", column)
    if not match:
        return None
    color = match.group("color")
    metric = match.group("metric")
    if metric == "detected_features":
        return "number_of_detected_features"
    if metric == "depth_m":
        return f"{color}_depth_m"
    if metric.startswith("detected_fov_"):
        return "right_display_fov." + metric.removeprefix("detected_fov_")
    if metric.startswith("frame_t_camera_extrinsic_"):
        return "right_frame_t_camera_extrinsic." + metric.removeprefix("frame_t_camera_extrinsic_").replace("_", ".", 1)
    return None


def parse_dgc_summary(path: Path, limits: dict[str, tuple[str, str]]) -> list[TestResult]:
    if not path.exists():
        return []
    headers, rows = read_csv_rows(path)
    if not rows:
        return []
    row = rows[-1]
    results: list[TestResult] = []
    for index, column in enumerate(headers):
        limit_key = dgc_limit_key(column)
        if not limit_key or index >= len(row) or not format_value(row[index]):
            continue
        minimum, maximum = limits.get(limit_key, ("", ""))
        results.append(TestResult(f"DGC.{column}", format_value(row[index]), minimum, maximum))
    return results


def parse_dgc_specs(path: Path) -> list[TestResult]:
    if not path.exists():
        return []

    results: list[TestResult] = []
    record: dict[str, str] = {}
    section = ""
    eyebox: list[str] = []

    def emit() -> None:
        if not record.get("color"):
            return
        prefix = f"DGC.{record.get('side', 'unknown')}.{record['color']}"
        if eyebox:
            prefix += ".eyebox_" + "_".join(eyebox)
        for key in ("number_of_detected_features", "depth_m"):
            if key in record:
                results.append(TestResult(f"{prefix}.{key}", record[key]))
        for key in ("detected_fov.top", "detected_fov.bottom", "detected_fov.left", "detected_fov.right"):
            if key in record:
                results.append(TestResult(f"{prefix}.{key}", record[key]))
        for key in ("display_center_angle.x", "display_center_angle.y"):
            if key in record:
                results.append(TestResult(f"{prefix}.{key}", record[key]))

    for raw_line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        line = raw_line.rstrip()
        color_match = re.match(r"^- color:\s*(\S+)", line)
        if color_match:
            emit()
            record = {"color": color_match.group(1)}
            section = ""
            eyebox = []
            continue
        side_match = re.match(r"^\s{2}side:\s*(\S+)", line)
        if side_match:
            record["side"] = side_match.group(1)
            continue
        if re.match(r"^\s{2}eyebox_position:\s*$", line):
            section = "eyebox_position"
            continue
        eyebox_match = re.match(rf"^\s{{4}}-\s*({NUMBER})\s*$", line)
        if section == "eyebox_position" and eyebox_match:
            eyebox.append(eyebox_match.group(1))
            continue
        section_match = re.match(r"^\s{2}(detected_fov|display_center_angle):\s*$", line)
        if section_match:
            section = section_match.group(1)
            continue
        scalar_match = re.match(rf"^\s{{2}}(number_of_detected_features|depth_m):\s*({NUMBER})\s*$", line)
        if scalar_match:
            section = ""
            record[scalar_match.group(1)] = scalar_match.group(2)
            continue
        nested_match = re.match(rf"^\s{{4}}(top|bottom|left|right|x|y):\s*({NUMBER})\s*$", line)
        if nested_match and section in {"detected_fov", "display_center_angle"}:
            record[f"{section}.{nested_match.group(1)}"] = nested_match.group(2)
    emit()
    return results


def parse_log(path: Path) -> list[TestResult]:
    if not path.exists():
        return []
    results: list[TestResult] = []
    auto_exposure_count = 0
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        if match := AUTO_EXPOSURE_RE.search(line):
            auto_exposure_count += 1
            results.append(
                TestResult(
                    name=f"DCC.auto_exposure.measured_intensity.{auto_exposure_count}",
                    reading=match.group("reading"),
                    minimum=format_value(match.group("minimum")),
                    maximum=format_value(match.group("maximum")),
                )
            )
        if match := XYZ_RE.search(line):
            asset = match.group("asset").lower()
            for axis in ("x", "y", "z"):
                results.append(TestResult(f"DCC.white_point.pre_cal.{asset}.XYZ.{axis.upper()}", match.group(axis)))
        if match := NORMALIZATION_RE.search(line):
            results.append(TestResult("DCC.white_point.solver.normalization_factor", match.group("value")))
        if match := SOLVER_FINAL_RE.match(line.strip()):
            results.append(TestResult("DCC.white_point.solver.final_cost", match.group("value")))
        if match := HARDWARE_AVERAGING_RE.search(line):
            results.append(TestResult("DCC.spectrometer.right.hardware_averaging_factor", match.group("value")))
    return results


def yaml_scalar(text: str, pattern: str) -> str:
    match = re.search(pattern, text, re.MULTILINE)
    return format_value(match.group("value")) if match else ""


def parse_dcc_metadata(dcc_root: Path) -> list[TestResult]:
    stages = {
        "pre_cal": dcc_root / "capture" / "device_metadata",
        "ok2cal": dcc_root / "whitepoint_ok2cal" / "capture" / "device_metadata",
        "post_cal": dcc_root / "white_point_calibration" / "post_cal_capture" / "device_metadata",
    }
    results: list[TestResult] = []
    for stage, metadata_dir in stages.items():
        paths = sorted(metadata_dir.glob("*.yaml"))
        if not paths:
            continue
        representative_text = paths[0].read_text(encoding="utf-8", errors="replace")
        shared_values = {
            "integration_time_us": yaml_scalar(representative_text, rf"^integration_times_us:\s*\n\s+right:\s*(?P<value>{NUMBER})"),
            "wavelength_shift_nm": yaml_scalar(representative_text, rf"^\s+wavelength_shift_nm:\s*(?P<value>{NUMBER})"),
            "display_brightness": yaml_scalar(representative_text, rf"^\s+display_brightness:\s*(?P<value>{NUMBER})"),
        }
        for metric, value in shared_values.items():
            if value:
                results.append(TestResult(f"DCC.{stage}.{metric}", value))
        for path in paths:
            text = path.read_text(encoding="utf-8", errors="replace")
            asset = path.stem.lower()
            temperature = yaml_scalar(
                text,
                rf"^\s+panel_temperature:\s*\n\s+right:\s*(?P<value>{NUMBER}|None|null)",
            )
            unsaturated = yaml_scalar(
                text,
                r"^unsaturated:\s*\n\s+right:\s*(?P<value>true|false|None|null)",
            )
            if temperature:
                results.append(TestResult(f"DCC.{stage}.{asset}.panel_temperature", temperature))
            if unsaturated:
                results.append(TestResult(f"DCC.{stage}.{asset}.unsaturated", unsaturated))
    return results


def parse_color_correction(path: Path) -> dict[str, str]:
    if not path.exists():
        return {}
    text = path.read_text(encoding="utf-8", errors="replace")
    readings: dict[str, str] = {}
    for metric in ("white_residual",):
        value = yaml_scalar(text, rf"^\s*{metric}:\s*(?P<value>{NUMBER})")
        if value:
            readings[metric] = value
    final_cost = yaml_scalar(text, rf"^\s*final_cost:\s*(?P<value>{NUMBER})")
    num_measurements = yaml_scalar(text, r"^num_measurements:\s*(?P<value>\d+)")
    if final_cost and num_measurements and float(num_measurements) > 0:
        readings["total_residual"] = format(math.sqrt(2 * float(final_cost) / float(num_measurements)), ".15g")
    return readings


def resolve_dcc_specs_path(dcc_root: Path, robocal_root: Path | None) -> Path | None:
    config_path = dcc_root / "dcc_config.json"
    if not config_path.exists():
        return None
    config = json.loads(config_path.read_text(encoding="utf-8", errors="replace"))
    configured_value = config.get("processing", {}).get("limits", {}).get("limits_file")
    if not configured_value:
        return None

    configured_path = Path(configured_value)
    candidates = [configured_path]
    source_roots = [robocal_root] if robocal_root else []
    default_source_root = Path.home() / "Robocal-v4"
    if default_source_root not in source_roots:
        source_roots.append(default_source_root)
    configured_parts = configured_path.parts
    marker_index = next(
        (index for index, part in enumerate(configured_parts) if part.lower() == "dgcc_standalone_station"),
        None,
    )
    if marker_index is not None:
        relative_path = Path(*configured_parts[marker_index:])
        candidates.extend(source_root / relative_path for source_root in source_roots if source_root)
    return next((path for path in candidates if path.exists()), None)


def parse_dcc_specs(path: Path, readings: dict[str, str]) -> list[TestResult]:
    results: list[TestResult] = []
    metric = ""
    properties: dict[str, str] = {}

    def emit() -> None:
        if not metric or "limit" not in properties or "limit_type" not in properties:
            return
        eyes_match = re.search(r"\[(?P<eyes>[^]]+)\]", properties.get("eyes", ""))
        eyes = [eye.strip(" '\"") for eye in eyes_match.group("eyes").split(",")] if eyes_match else [""]
        stage = properties.get("measurement_stage", "post_calibration")
        for eye in eyes:
            name = f"DCC.{stage}.{metric}.{eye}" if eye else f"DCC.{stage}.{metric}"
            minimum = properties["limit"] if properties["limit_type"].lower() == "minimum" else ""
            maximum = properties["limit"] if properties["limit_type"].lower() == "maximum" else ""
            results.append(TestResult(name, readings.get(metric, ""), minimum, maximum))

    for raw_line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        top_level = re.match(r"^(?P<metric>[A-Za-z0-9_]+):\s*$", raw_line)
        if top_level:
            emit()
            metric = top_level.group("metric")
            properties = {}
            continue
        property_match = re.match(
            r"^\s{2}(?P<key>eyes|limit|limit_type|measurement_stage):\s*(?P<value>.+?)\s*$",
            raw_line,
        )
        if property_match:
            properties[property_match.group("key")] = property_match.group("value").strip(" '\"")
    emit()
    return results


def read_csv_rows(path: Path) -> tuple[list[str], list[list[str]]]:
    with path.open("r", encoding="utf-8-sig", errors="replace", newline="") as handle:
        rows = list(csv.reader(handle))
    if not rows:
        raise ValueError(f"CSV is empty: {path}")
    width = max(len(row) for row in rows)
    return rows[0] + [""] * (width - len(rows[0])), [row + [""] * (width - len(row)) for row in rows[1:]]


def parse_limits_summary(path: Path) -> list[TestResult]:
    headers, rows = read_csv_rows(path)
    normalized = {normalize_header(header): index for index, header in enumerate(headers)}
    if {"limitname", "value", "limitvalue", "limittype"}.issubset(normalized):
        def summary_cell(row: Sequence[str], field: str, default: str = "") -> str:
            index = normalized.get(field)
            return format_value(row[index]) if index is not None and index < len(row) else default

        results: list[TestResult] = []
        for row in rows:
            metric = summary_cell(row, "limitname")
            if not metric:
                continue
            stage = summary_cell(row, "measurementstage", "post_calibration")
            eye = summary_cell(row, "eye")
            name = f"DCC.{stage}.{metric}.{eye}" if eye else f"DCC.{stage}.{metric}"
            limit_value = summary_cell(row, "limitvalue")
            limit_type = summary_cell(row, "limittype").lower()
            minimum = limit_value if limit_type == "minimum" else ""
            maximum = limit_value if limit_type == "maximum" else ""
            results.append(TestResult(name, summary_cell(row, "value"), minimum, maximum))
        return results

    columns = {field: find_column(headers, field) for field in HEADER_ALIASES}
    if columns["name"] is None or columns["reading"] is None:
        raise ValueError(f"Limits summary lacks test-name/reading columns: {path}")

    def cell(row: Sequence[str], field: str) -> str:
        index = columns[field]
        return format_value(row[index]) if index is not None and index < len(row) else ""

    return [TestResult(cell(row, "name"), cell(row, "reading"), cell(row, "minimum"), cell(row, "maximum")) for row in rows if cell(row, "name")]


def collect_results(
    root: Path,
    run_id: str,
    robocal_root: Path | None = None,
    station_config: Path | None = None,
) -> tuple[list[TestResult], list[str]]:
    sources = [
        root / "DCC" / run_id / "dcc_limits_summary.csv",
        root / "DGC" / run_id / "nominal_workflow_calibration" / "calibration_specs.yaml",
        root / f"log_file_{run_id}.log",
    ]
    results: list[TestResult] = []
    warnings: list[str] = []
    dcc_root = root / "DCC" / run_id
    if sources[0].exists():
        results.extend(parse_limits_summary(sources[0]))
    else:
        specs_path = resolve_dcc_specs_path(dcc_root, robocal_root)
        if specs_path:
            readings = parse_color_correction(
                dcc_root / "white_point_calibration" / "correction" / "right" / "color_correction.textproto"
            )
            spec_results = parse_dcc_specs(specs_path, readings)
            results.extend(spec_results)
            missing_readings = sum(not result.reading for result in spec_results)
            warnings.append(
                f"{run_id}: dcc_limits_summary.csv not found; loaded {len(spec_results)} specs from {specs_path}, "
                f"but {missing_readings} readings are unavailable"
            )
        else:
            warnings.append(f"{run_id}: DCC limits summary and configured specs YAML were not found")
    results.extend(parse_dgc_specs(sources[1]))
    dgc_limits_path = resolve_dgc_limits_path(station_config, robocal_root)
    dgc_limits = parse_dgc_limits(dgc_limits_path) if dgc_limits_path else {}
    results.extend(parse_dgc_summary(root / "DGC" / run_id / "DGC_full_summary.csv", dgc_limits))
    if (root / "DGC" / run_id / "DGC_full_summary.csv").exists() and not dgc_limits_path:
        warnings.append(f"{run_id}: DGC summary found, but display specs could not be resolved from station config")
    results.extend(parse_log(sources[2]))
    results.extend(parse_dcc_metadata(dcc_root))

    deduplicated: dict[str, TestResult] = {}
    for result in results:
        deduplicated[result.name] = result
    return list(deduplicated.values()), warnings


def write_report(path: Path, results: Iterable[TestResult], template: Path | None) -> None:
    result_list = list(results)
    if template:
        headers, rows = read_csv_rows(template)
    else:
        headers, rows = DEFAULT_HEADERS.copy(), []
    columns = {field: find_column(headers, field) for field in HEADER_ALIASES}
    missing = [field for field, index in columns.items() if index is None]
    if missing:
        raise ValueError(f"Template {template} does not contain recognizable columns: {', '.join(missing)}")

    name_index = columns["name"]
    assert name_index is not None
    existing = {row[name_index].strip(): row for row in rows if name_index < len(row) and row[name_index].strip()}
    for result in result_list:
        row = existing.get(result.name)
        if row is None:
            row = [""] * len(headers)
            rows.append(row)
            existing[result.name] = row
        values = {"name": result.name, "reading": result.reading, "minimum": result.minimum, "maximum": result.maximum}
        for field, value in values.items():
            index = columns[field]
            assert index is not None
            row[index] = value

    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.writer(handle, lineterminator="\n")
        writer.writerow(headers)
        writer.writerows(rows)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Generate CSV test reports from a RoboCal workspace")
    parser.add_argument("input", nargs="?", default=".", type=Path, help="RoboCal workspace root")
    parser.add_argument("--run", help="Run timestamp such as 20260729_085628; defaults to latest")
    parser.add_argument("--all-runs", action="store_true", help="Generate one report for every discovered run")
    parser.add_argument(
        "--official-only",
        action="store_true",
        help="Only include rows with an explicit minimum or maximum production spec",
    )
    parser.add_argument("--template", type=Path, help="ML_Robocal.csv template to preserve and fill")
    parser.add_argument("--robocal-root", type=Path, help="RoboCal source root used to resolve configured specs YAML")
    parser.add_argument("--station-config", type=Path, help="RoboCal station YAML used to resolve the DGC recipe and specs")
    parser.add_argument("--output", type=Path, default=Path("generated_reports"), help="Output CSV or directory")
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    root = resolve_post_process_root(args.input.resolve())
    runs = discover_runs(root)
    if not runs:
        print(f"error: no RoboCal runs found under {root}", file=sys.stderr)
        return 2
    if args.run and args.run not in runs:
        print(f"error: run {args.run} not found; available: {', '.join(runs)}", file=sys.stderr)
        return 2
    selected = runs if args.all_runs else [args.run or runs[-1]]
    output_is_csv = args.output.suffix.lower() == ".csv"
    if output_is_csv and len(selected) > 1:
        print("error: --output must be a directory with --all-runs", file=sys.stderr)
        return 2

    try:
        for run_id in selected:
            results, warnings = collect_results(root, run_id, args.robocal_root, args.station_config)
            if args.official_only:
                results = [result for result in results if result.minimum or result.maximum]
            output = args.output if output_is_csv else args.output / f"ML_Robocal_{run_id}.csv"
            write_report(output, results, args.template)
            print(f"{run_id}: wrote {len(results)} tests to {output}")
            for warning in warnings:
                print(f"warning: {warning}", file=sys.stderr)
    except (OSError, ValueError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
