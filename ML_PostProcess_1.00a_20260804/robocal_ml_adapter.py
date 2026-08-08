#!/usr/bin/env python3
"""Append a generated RoboCal report to an existing ML-format CSV."""

from __future__ import annotations

import argparse
import csv
import os
import sys
import tempfile
from pathlib import Path
from typing import Sequence


SOURCE_ALIASES = {
    "name": {"testname", "test", "name", "metric", "item"},
    "reading": {"reading", "measured", "measuredvalue", "value", "result"},
    "minimum": {"minimumspec", "minspec", "minimum", "min", "lowerlimit", "lowerbound", "lsl"},
    "maximum": {"maximumspec", "maxspec", "maximum", "max", "upperlimit", "upperbound", "usl"},
}
ML_COLUMNS = ("TestName", "Value", "LowerLimit", "UpperLimit")
TRAILING_TEST_NAMES = {"tcstestsuiteduration"}


def normalize_header(value: str) -> str:
    return "".join(character for character in value.strip().lower() if character.isalnum())


def read_csv(path: Path) -> tuple[list[str], list[list[str]]]:
    with path.open("r", encoding="utf-8-sig", errors="replace", newline="") as handle:
        rows = list(csv.reader(handle))
    if not rows:
        raise ValueError(f"CSV is empty: {path}")
    width = len(rows[0])
    if not width:
        raise ValueError(f"CSV has no columns: {path}")
    normalized_rows = [row[:width] + [""] * max(0, width - len(row)) for row in rows[1:]]
    return rows[0], normalized_rows


def find_source_columns(headers: Sequence[str]) -> dict[str, int]:
    normalized = [normalize_header(header) for header in headers]
    columns: dict[str, int] = {}
    for field, aliases in SOURCE_ALIASES.items():
        index = next((index for index, header in enumerate(normalized) if header in aliases), None)
        if index is None:
            raise ValueError(f"Generated report is missing a recognizable {field} column")
        columns[field] = index
    return columns


def find_ml_columns(headers: Sequence[str]) -> dict[str, int]:
    normalized = {normalize_header(header): index for index, header in enumerate(headers)}
    missing = [column for column in ML_COLUMNS if normalize_header(column) not in normalized]
    if missing:
        raise ValueError(f"ML template is missing columns: {', '.join(missing)}")
    return {column: normalized[normalize_header(column)] for column in ML_COLUMNS}


def append_report(
    template: Path,
    report: Path,
    output: Path,
    replace_tests: bool = False,
    serial_number: str | None = None,
) -> int:
    ml_headers, ml_rows = read_csv(template)
    if not ml_rows:
        raise ValueError(f"ML template has no data row to inherit: {template}")
    source_headers, source_rows = read_csv(report)
    source_columns = find_source_columns(source_headers)
    ml_columns = find_ml_columns(ml_headers)
    normalized_ml_headers = {normalize_header(header): index for index, header in enumerate(ml_headers)}
    generated_rows = [
        row for row in source_rows if row[source_columns["name"]].strip()
    ]
    generated_names = {row[source_columns["name"]].strip() for row in generated_rows}
    if replace_tests:
        ml_rows = [row for row in ml_rows if row[ml_columns["TestName"]].strip() not in generated_names]

    test_name_index = ml_columns["TestName"]
    trailing_rows = [
        row for row in ml_rows if normalize_header(row[test_name_index]) in TRAILING_TEST_NAMES
    ]
    ml_rows = [
        row for row in ml_rows if normalize_header(row[test_name_index]) not in TRAILING_TEST_NAMES
    ]
    inherited_row = (trailing_rows[-1] if trailing_rows else ml_rows[-1]).copy()

    appended = 0
    for source_row in generated_rows:
        test_name = source_row[source_columns["name"]].strip()
        row = inherited_row.copy()
        row[ml_columns["TestName"]] = test_name
        row[ml_columns["Value"]] = source_row[source_columns["reading"]].strip()
        row[ml_columns["LowerLimit"]] = source_row[source_columns["minimum"]].strip()
        row[ml_columns["UpperLimit"]] = source_row[source_columns["maximum"]].strip()
        for measurement_field in ("measurementname", "units"):
            if measurement_field in normalized_ml_headers:
                row[normalized_ml_headers[measurement_field]] = ""
        if serial_number and "serialnumber" in normalized_ml_headers:
            row[normalized_ml_headers["serialnumber"]] = serial_number
        ml_rows.append(row)
        appended += 1
    ml_rows.extend(trailing_rows)

    output.parent.mkdir(parents=True, exist_ok=True)
    temporary_path: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w",
            encoding="utf-8-sig",
            newline="",
            dir=output.parent,
            prefix=f".{output.name}.",
            suffix=".tmp",
            delete=False,
        ) as handle:
            temporary_path = Path(handle.name)
            writer = csv.writer(handle, lineterminator="\n")
            writer.writerow(ml_headers)
            writer.writerows(ml_rows)
        os.replace(temporary_path, output)
    finally:
        if temporary_path and temporary_path.exists():
            temporary_path.unlink()
    return appended


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Append a generated RoboCal report to an ML-format CSV")
    parser.add_argument("report", type=Path, help="Generated four-column RoboCal CSV")
    parser.add_argument("--template", required=True, type=Path, help="Existing ML-format CSV with a row to inherit")
    parser.add_argument("--output", required=True, type=Path, help="Output ML-format CSV")
    parser.add_argument("--replace-tests", action="store_true", help="Replace existing rows with matching test names")
    parser.add_argument("--serial-number", help="Serial number to write into generated ML rows")
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        appended = append_report(args.template, args.report, args.output, args.replace_tests, args.serial_number)
    except (OSError, ValueError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    print(f"appended {appended} tests from {args.report} to {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
