@echo off
setlocal EnableExtensions

if /i "%~1"=="/?" goto :usage
if /i "%~1"=="--help" goto :usage

set "REMOTE=%~3"
if "%REMOTE%"=="" set "REMOTE=gdrive"

set "SOURCE=%~1"
if "%SOURCE%"=="" (
  set /p "SOURCE=Local folder to upload: "
)

set "DRIVE_URL=%~2"
if "%DRIVE_URL%"=="" (
  set /p "DRIVE_URL=Google Drive folder URL or folder ID: "
)

if "%SOURCE:~-1%"=="\" set "SOURCE=%SOURCE:~0,-1%"
for %%I in ("%SOURCE%") do set "DESTINATION_FOLDER=%%~nxI"

set "ROOT_FOLDER_ID=%DRIVE_URL:https://drive.google.com/drive/folders/=%"
for /f "tokens=1 delims=?/" %%I in ("%ROOT_FOLDER_ID%") do set "ROOT_FOLDER_ID=%%I"

if "%ROOT_FOLDER_ID%"=="" (
  echo ERROR: A Google Drive folder URL or folder ID is required.
  exit /b 1
)

set "LOG_DIR=%~dp0logs"
if "%LOG_DIR%"=="\logs" set "LOG_DIR=%CD%\logs"
set "LOG_FILE=%LOG_DIR%\rclone-upload-%DESTINATION_FOLDER%.log"

if not exist "%SOURCE%\" (
  echo ERROR: Source folder does not exist: "%SOURCE%"
  exit /b 2
)

where rclone >nul 2>&1
if errorlevel 1 (
  echo ERROR: rclone was not found on PATH.
  echo Install it with: winget install --id Rclone.Rclone --exact
  exit /b 3
)

if not exist "%LOG_DIR%\" mkdir "%LOG_DIR%"

echo Checking access to the Google Drive destination...
rclone lsd "%REMOTE%:" --drive-root-folder-id "%ROOT_FOLDER_ID%" --log-file "%LOG_FILE%" --log-level INFO
if errorlevel 1 (
  echo ERROR: Cannot access the Google Drive destination.
  echo Complete "rclone config" and authorize the "%REMOTE%" remote, then retry.
  exit /b 4
)

echo Creating the destination folder if needed...
rclone mkdir "%REMOTE%:%DESTINATION_FOLDER%" --drive-root-folder-id "%ROOT_FOLDER_ID%" --log-file "%LOG_FILE%" --log-level INFO
if errorlevel 1 (
  echo ERROR: Could not create or access the destination folder.
  exit /b 5
)

if exist "%SOURCE%\Robocal\" (
  call :MOVE_LEGACY_ROBOCAL_FOLDER DGC
  if errorlevel 1 exit /b 6
  call :MOVE_LEGACY_ROBOCAL_FOLDER DCC
  if errorlevel 1 exit /b 6
)

echo Uploading "%SOURCE%" to Google Drive...
rclone copy "%SOURCE%" "%REMOTE%:%DESTINATION_FOLDER%" ^
  --drive-root-folder-id "%ROOT_FOLDER_ID%" ^
  --progress ^
  --stats 30s ^
  --transfers 8 ^
  --checkers 8 ^
  --drive-chunk-size 128M ^
  --retries 10 ^
  --low-level-retries 20 ^
  --log-file "%LOG_FILE%" ^
  --log-level INFO

if errorlevel 1 (
  echo ERROR: Upload did not complete. Review "%LOG_FILE%" and run this batch again.
  exit /b 6
)

echo Upload completed successfully.
echo Log: "%LOG_FILE%"
exit /b 0

:MOVE_LEGACY_ROBOCAL_FOLDER
rclone lsf "%REMOTE%:%DESTINATION_FOLDER%/%~1" --drive-root-folder-id "%ROOT_FOLDER_ID%" --max-depth 1 --log-file "%LOG_FILE%" --log-level INFO >nul 2>&1
if errorlevel 1 exit /b 0

echo Moving Google Drive folder "%DESTINATION_FOLDER%/%~1" under Robocal...
rclone mkdir "%REMOTE%:%DESTINATION_FOLDER%/Robocal/%~1" --drive-root-folder-id "%ROOT_FOLDER_ID%" --log-file "%LOG_FILE%" --log-level INFO
if errorlevel 1 exit /b 1
rclone move "%REMOTE%:%DESTINATION_FOLDER%/%~1" "%REMOTE%:%DESTINATION_FOLDER%/Robocal/%~1" --drive-root-folder-id "%ROOT_FOLDER_ID%" --delete-empty-src-dirs --log-file "%LOG_FILE%" --log-level INFO
if errorlevel 1 exit /b 1
rclone rmdir "%REMOTE%:%DESTINATION_FOLDER%/%~1" --drive-root-folder-id "%ROOT_FOLDER_ID%" --log-file "%LOG_FILE%" --log-level INFO >nul 2>&1
exit /b 0

:usage
echo Usage:
echo   %~nx0 "LOCAL_FOLDER" "GOOGLE_DRIVE_FOLDER_URL_OR_ID" [RCLONE_REMOTE]
echo.
echo Examples:
echo   %~nx0 "D:\RoboGRR\S6A67340005X" "https://drive.google.com/drive/folders/1PLmAKzagiYLUTX2Eqh8S_fDR1nE6tC5E"
echo   %~nx0 "D:\RoboGRR\S6A67340005X" "1PLmAKzagiYLUTX2Eqh8S_fDR1nE6tC5E" "gdrive"
echo.
echo Run without arguments to enter the local folder and Google Drive URL interactively.
exit /b 0
