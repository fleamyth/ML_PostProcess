# ML_Robocal

## Google Drive uploads

The production entry point is `_Online_PostProcess.bat`, which calls
`START.bat PostProcess`. `START.bat` selects
`ML_PostProcess_1.00a_20260804\Tools\upload_Folder_to_google_drive.bat`.
`FOLDER.ini` is not used to select this upload tool.

Online TS uploads use folder ID `1U9hKoGkFsbvxEMnuKuYXAAUKrL1CcUBn`:
https://drive.google.com/drive/folders/1U9hKoGkFsbvxEMnuKuYXAAUKrL1CcUBn

The source remains `C:\logs\<LOG_IDENTIFIER>` and the remote path remains
`<yyyyMMdd>/<LOG_IDENTIFIER>`. `LOG_IDENTIFIER` is the device serial property,
falling back to the scanned SN. Station folders retain their existing layout:
`Robocal` and `PostProcess` become `Robocal.zip` and `PostProcess.zip`; other
files are copied as before. PASS/FAIL timing and background uploads are
unchanged. The background worker now returns the uploader's failure status.

Debug (`_Debug_PostProcess.bat`, mode `D`) retains its previous destination.
The three `*- GRR.bat` scripts retain their independent destinations and tool
paths; their separate pre-process tool paths are not changed by this fix.

### Shared uploader

```bat
ML_PostProcess_1.00a_20260804\Tools\upload_Folder_to_google_drive.bat "LOCAL_FOLDER" "FOLDER_ID_OR_URL" "gdrive" "DATE/SN"
```

The destination accepts a raw folder ID or an HTTPS `drive.google.com` URL
with `/drive/folders/<ID>` or `/drive/u/2/folders/<ID>` (any numeric account
index). A trailing slash, query such as `?usp=sharing`, and `#fragment` are
supported. Other URLs and malformed IDs fail before any rclone operation.
The URL account index does **not** select a Google account: access uses the
existing authorization of the specified rclone remote. No OAuth settings
are changed.

A read-only root access check runs before folder creation or transfers.
Access-check failure returns code 4; destination creation failure returns
code 5; ZIP or transfer failure returns code 6. Invalid destinations return
code 1. Check `Tools\logs\rclone-upload-<source-folder-name>.log` for the
underlying Google error: `403 rateLimitExceeded` indicates API throttling or
quota, whereas permission/authentication errors require checking the remote
account's access. A `404` can mean a wrong ID or a folder hidden from that
account; do not treat it as proof that URL parsing failed. Preflight checks
have bounded retries and never proceed to transfers on failure.

### Offline regression tests (Windows)

```powershell
python -m unittest discover -s tests -p test_google_drive_upload.py -v
```

These tests run the real batch uploader against a compiled fake `rclone.exe`
inside a temporary directory. They check URL parsing, remote subdirectories,
ZIP layout, failure propagation and production/Debug/GRR configuration.
They require Windows PowerShell and the bundled `7za.exe`, use only synthetic
text, and never contact Google Drive. Passing them does not establish that
production credentials, permissions, API quota or hardware-triggered uploads
work.