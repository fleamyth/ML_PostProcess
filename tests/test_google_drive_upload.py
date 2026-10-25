import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
import zipfile


ROOT = Path(__file__).resolve().parents[1]
TOOLS = ROOT / "ML_PostProcess_1.00a_20260804" / "Tools"
FOLDER_ID = "1U9hKoGkFsbvxEMnuKuYXAAUKrL1CcUBn"
OLD_ID = "1VuN9N7JXBBuHByXVgUjm1jEw18wSW_N6"

FAKE_RCLONE = r"""
using System;
using System.IO;
public class FakeRclone {
    public static int Main(string[] args) {
        File.AppendAllText(Environment.GetEnvironmentVariable("MOCK_CALLS"),
            string.Join("\t", args) + Environment.NewLine);
        if (args[0] == Environment.GetEnvironmentVariable("MOCK_FAIL")) {
            Console.Error.WriteLine(Environment.GetEnvironmentVariable("MOCK_ERROR"));
            return 9;
        }
        if (args[0] == "copyto") {
            File.Copy(args[1], Path.Combine(
                Environment.GetEnvironmentVariable("MOCK_CAPTURE"),
                Path.GetFileName(args[1])), true);
        }
        return 0;
    }
}
"""


@unittest.skipUnless(os.name == "nt", "Windows batch integration tests")
class GoogleDriveUploadTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.fixture = tempfile.TemporaryDirectory(prefix="drive-upload-tests-")
        cls.addClassCleanup(cls.fixture.cleanup)
        cls.base = Path(cls.fixture.name)
        cls.bin = cls.base / "bin"
        cls.bin.mkdir()
        cs_path = cls.base / "FakeRclone.cs"
        cs_path.write_text(FAKE_RCLONE, encoding="ascii")
        compiled = subprocess.run(
            [
                "powershell.exe", "-NoProfile", "-Command",
                "Add-Type -Path $env:MOCK_CS -OutputAssembly "
                "$env:MOCK_EXE -OutputType ConsoleApplication",
            ],
            env={
                **os.environ,
                "MOCK_CS": str(cs_path),
                "MOCK_EXE": str(cls.bin / "rclone.exe"),
            },
            capture_output=True, text=True, timeout=60,
        )
        if compiled.returncode:
            raise RuntimeError(compiled.stdout + compiled.stderr)
        cls.uploader = cls.bin / "upload_Folder_to_google_drive.bat"
        shutil.copy2(TOOLS / cls.uploader.name, cls.uploader)
        (cls.bin / "7z").mkdir()
        shutil.copy2(TOOLS / "7z" / "7za.exe", cls.bin / "7z" / "7za.exe")

    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(dir=self.base)
        self.addCleanup(self.temporary.cleanup)
        self.work = Path(self.temporary.name)
        self.source = self.work / "Synthetic SN"
        self.source.mkdir()
        (self.source / "sample.txt").write_text("Offline upload test only.\n")
        self.calls_file = self.work / "calls.txt"
        self.capture = self.work / "capture"
        self.capture.mkdir()
        self.env = {
            **os.environ,
            "PATH": str(self.bin) + os.pathsep + os.environ["PATH"],
            "MOCK_CALLS": str(self.calls_file),
            "MOCK_CAPTURE": str(self.capture),
            "MOCK_FAIL": "",
            "MOCK_ERROR": "",
        }

    def run_batch(self, script, arguments=(), env=None):
        command = "call " + " ".join(
            '"' + str(value) + '"' for value in (script, *arguments)
        )
        return subprocess.run(
            f'"{os.environ["COMSPEC"]}" /d /s /c "{command}"',
            env=self.env if env is None else env, cwd=self.work,
            capture_output=True, text=True, timeout=45,
        )

    def upload(self, destination=FOLDER_ID, path="20261025/SYNTHETIC_SN"):
        arguments = [self.source, destination, "gdrive"]
        if path is not None:
            arguments.append(path)
        return self.run_batch(self.uploader, arguments)

    def calls(self):
        if not self.calls_file.exists():
            return []
        return [
            line.split("\t")
            for line in self.calls_file.read_text().splitlines()
        ]

    def clear_calls(self):
        self.calls_file.unlink(missing_ok=True)

    def assert_success(self, result):
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_supported_folder_formats(self):
        formats = [FOLDER_ID]
        for prefix in ("drive/folders/", "drive/u/2/folders/"):
            for suffix in ("", "/", "?usp=sharing", "#fragment",
                           "/?usp=sharing", "/#fragment",
                           "?usp=sharing#fragment", "/?usp=sharing#fragment",
                           "?usp=sharing&foo=bar"):
                formats.append("https://drive.google.com/" + prefix + FOLDER_ID + suffix)
        for value in formats:
            with self.subTest(value=value):
                self.clear_calls()
                self.assert_success(self.upload(value))
                self.assertEqual([call[0] for call in self.calls()],
                                 ["lsd", "mkdir", "copy"])
                for call in self.calls():
                    index = call.index("--drive-root-folder-id")
                    self.assertEqual(call[index + 1], FOLDER_ID)
                self.assertEqual(self.calls()[1][1],
                                 "gdrive:20261025/SYNTHETIC_SN")

    def test_invalid_destinations_never_call_rclone(self):
        invalid = [
            "https:", "https://drive.google.com",
            "https://drive.google.com/drive/folders/",
            "https://drive.google.com/drive/u/two/folders/" + FOLDER_ID,
            "https://drive.google.com/drive/folders/" + FOLDER_ID + "/child",
            "https://example.com/drive/folders/" + FOLDER_ID,
            "https://drive.google.com.evil.example/drive/folders/" + FOLDER_ID,
            "http://drive.google.com/drive/folders/" + FOLDER_ID,
            "https://drive.google.com/open?id=" + FOLDER_ID,
            "bad id", "../folder", "gdrive:", "bad!id",
        ]
        for value in invalid:
            with self.subTest(value=value):
                self.clear_calls()
                result = self.upload(value)
                self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
                self.assertIn("ERROR: Invalid Google Drive", result.stdout)
                self.assertEqual(self.calls(), [])

    def test_default_destination_is_source_folder_name(self):
        self.assert_success(self.upload(path=None))
        self.assertEqual(self.calls()[1][1], "gdrive:Synthetic SN")
        self.assertEqual(self.calls()[2][2], "gdrive:Synthetic SN")

    def test_station_zip_layout_and_remaining_files(self):
        for station in ("Robocal", "PostProcess"):
            (self.source / station).mkdir()
            (self.source / station / "station.txt").write_text("Synthetic station.\n")
        self.assert_success(self.upload())
        calls = self.calls()
        self.assertEqual([call[0] for call in calls],
                         ["lsd", "mkdir", "copyto", "copyto", "copy"])
        for call, station in zip(calls[2:4], ("Robocal", "PostProcess")):
            self.assertEqual(call[2],
                             f"gdrive:20261025/SYNTHETIC_SN/{station}.zip")
            with zipfile.ZipFile(self.capture / Path(call[1]).name) as archive:
                self.assertIn(f"{station}/station.txt", archive.namelist())
        self.assertEqual(calls[-1][1], str(self.source))
        self.assertEqual(calls[-1][2], "gdrive:20261025/SYNTHETIC_SN")
        exclusions = [calls[-1][i + 1] for i, arg in enumerate(calls[-1])
                      if arg == "--exclude"]
        self.assertEqual(exclusions, ["/Robocal/**", "/PostProcess/**"])
        self.assertFalse((self.source.parent / ".upload-temp").exists())

    def test_access_failure_stops_before_writes(self):
        for message in ("403 rateLimitExceeded", "404 notFound",
                        "403 insufficientFilePermissions", "401 unauthorized"):
            with self.subTest(message=message):
                self.clear_calls()
                self.env.update(MOCK_FAIL="lsd", MOCK_ERROR=message)
                result = self.upload()
                self.assertEqual(result.returncode, 4, result.stdout + result.stderr)
                self.assertIn(message, result.stderr)
                self.assertNotIn("Upload completed successfully", result.stdout)
                self.assertEqual([call[0] for call in self.calls()], ["lsd"])
                self.assertIn("--low-level-retries", self.calls()[0])

    def test_destination_creation_failure_stops_before_transfer(self):
        self.env.update(MOCK_FAIL="mkdir", MOCK_ERROR="403 forbidden")
        result = self.upload()
        self.assertEqual(result.returncode, 5, result.stdout + result.stderr)
        self.assertEqual([call[0] for call in self.calls()], ["lsd", "mkdir"])

    def test_copy_failure_is_not_success(self):
        self.env.update(MOCK_FAIL="copy", MOCK_ERROR="403 rateLimitExceeded")
        result = self.upload()
        self.assertEqual(result.returncode, 6, result.stdout + result.stderr)
        self.assertNotIn("Upload completed successfully", result.stdout)

    def test_zip_upload_failure_stops_remaining_transfers(self):
        (self.source / "Robocal").mkdir()
        (self.source / "Robocal" / "station.txt").write_text("Synthetic station.\n")
        self.env.update(MOCK_FAIL="copyto", MOCK_ERROR="403 forbidden")
        result = self.upload()
        self.assertEqual(result.returncode, 6, result.stdout + result.stderr)
        self.assertEqual([call[0] for call in self.calls()],
                         ["lsd", "mkdir", "copyto"])
        self.assertFalse((self.source.parent / ".upload-temp").exists())

    def test_production_and_debug_destinations(self):
        start = (ROOT / "START.bat").read_text()
        assignments = [
            line for line in start.splitlines()
            if 'SET "GOOGLE_DRIVE_URL=' in line
        ]
        fixture = self.work / "destination.bat"
        fixture.write_text("@echo off\n" + "\n".join(assignments)
                           + "\necho %GOOGLE_DRIVE_URL%\n")
        for mode, expected in (("", FOLDER_ID), ("D", OLD_ID), ("d", OLD_ID)):
            with self.subTest(mode=mode):
                result = self.run_batch(fixture, env={**self.env, "MODE": mode})
                self.assert_success(result)
                self.assertIn(expected, result.stdout)
        self.assertIn('"%GOOGLE_DRIVE_DATE%/%LOG_IDENTIFIER%"', start)
        self.assertIn('SET "GOOGLE_DRIVE_SOURCE=%LOG_ARCHIVE_ROOT%\\%LOG_IDENTIFIER%"',
                      start)
        for script in ("pre_process - GRR.bat", "post_process - GRR.bat",
                       "robocal - GRR.bat"):
            content = (ROOT / script).read_text()
            self.assertIn(OLD_ID, content)
            self.assertNotIn(FOLDER_ID, content)

    def test_background_worker_propagates_failure(self):
        start = (ROOT / "START.bat").read_text()
        worker = start.split("\n:UPLOAD_GRR_WORKER\n", 1)[1].split("\n:Record\n", 1)[0]
        fixture = self.work / "worker.bat"
        fixture.write_text("@echo off\n" + worker
                           + "\n:UPLOAD_GRR_TO_GOOGLE_DRIVE\nexit /b 4\n")
        result = self.run_batch(fixture)
        self.assertEqual(result.returncode, 4, result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
