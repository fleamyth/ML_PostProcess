@echo off
setlocal EnableExtensions DisableDelayedExpansion

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
set "DESTINATION_PATH=%~4"
if "%DESTINATION_PATH%"=="" set "DESTINATION_PATH=%DESTINATION_FOLDER%"

set "ROOT_FOLDER_ID="
for /f "usebackq delims=" %%I in (`powershell.exe -NoProfile -Command "$value=$env:DRIVE_URL; if($value -cmatch '\A[A-Za-z0-9_-]+\z'){Write-Output $value} elseif($value -match '\Ahttps://drive[.]google[.]com/drive/(?:u/[0-9]+/)?folders/([A-Za-z0-9_-]+)/?(?:\?[^#\s]*)?(?:#[^\s]*)?\z'){Write-Output $Matches[1]} else {Write-Error 'Invalid Google Drive folder URL or ID.'; exit 1}"`) do set "ROOT_FOLDER_ID=%%I"

if "%ROOT_FOLDER_ID%"=="" (
  echo ERROR: Invalid Google Drive folder URL or folder ID. No files were uploaded.
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
rclone lsd "%REMOTE%:" --drive-root-folder-id "%ROOT_FOLDER_ID%" --retries 1 --low-level-retries 1 --contimeout 30s --timeout 1m --log-file "%LOG_FILE%" --log-level INFO
if errorlevel 1 (
  echo ERROR: Cannot access the Google Drive destination.
  echo Review "%LOG_FILE%" for API quota, authorization, folder permission or folder ID errors.
  echo No files were uploaded. The account is determined by the "%REMOTE%" remote authorization.
  exit /b 4
)

echo Creating the destination folder if needed...
rclone mkdir "%REMOTE%:%DESTINATION_PATH%" --drive-root-folder-id "%ROOT_FOLDER_ID%" --retries 1 --low-level-retries 1 --contimeout 30s --timeout 1m --log-file "%LOG_FILE%" --log-level INFO
if errorlevel 1 (
  echo ERROR: Could not create or access the destination folder.
  exit /b 5
)

if exist "%SOURCE%\Robocal\" (
  call :UPLOAD_FOLDER_ZIP "Robocal"
  if errorlevel 1 exit /b 6
)

if exist "%SOURCE%\PostProcess\" (
  call :UPLOAD_FOLDER_ZIP "PostProcess"
  if errorlevel 1 exit /b 6
)

echo Uploading remaining files from "%SOURCE%" to Google Drive...
rclone copy "%SOURCE%" "%REMOTE%:%DESTINATION_PATH%" ^
  --drive-root-folder-id "%ROOT_FOLDER_ID%" ^
  --progress ^
  --stats 30s ^
  --transfers 4 ^
  --checkers 8 ^
  --drive-chunk-size 64M ^
  --contimeout 30s ^
  --timeout 15m ^
  --retries 10 ^
  --low-level-retries 20 ^
  --exclude "/Robocal/**" ^
  --exclude "/PostProcess/**" ^
  --log-file "%LOG_FILE%" ^
  --log-level INFO

if errorlevel 1 (
  echo ERROR: Upload did not complete. Review "%LOG_FILE%" and run this batch again.
  exit /b 6
)

echo Upload completed successfully.
echo Log: "%LOG_FILE%"
exit /b 0

:UPLOAD_FOLDER_ZIP
set "ZIP_FOLDER_NAME=%~1"
for %%I in ("%SOURCE%") do set "ZIP_TEMP_DIR=%%~dpI.upload-temp"
set "ZIP_FILE=%ZIP_TEMP_DIR%\%DESTINATION_FOLDER%_%ZIP_FOLDER_NAME%_%RANDOM%_%RANDOM%.zip"
if not exist "%ZIP_TEMP_DIR%\" mkdir "%ZIP_TEMP_DIR%" 2>nul
if not exist "%ZIP_TEMP_DIR%\" (
  echo ERROR: Could not create ZIP temporary directory: "%ZIP_TEMP_DIR%"
  exit /b 1
)

echo Packaging "%SOURCE%\%ZIP_FOLDER_NAME%" as %ZIP_FOLDER_NAME%.zip...
pushd "%SOURCE%"
"%~dp07z\7za.exe" a -tzip -mx=0 "%ZIP_FILE%" "%ZIP_FOLDER_NAME%"
set "ZIP_EXITCODE=%ERRORLEVEL%"
popd
if not "%ZIP_EXITCODE%"=="0" goto :ZIP_FAIL

"%~dp07z\7za.exe" t "%ZIP_FILE%" >nul
if errorlevel 1 goto :ZIP_FAIL

echo Uploading %ZIP_FOLDER_NAME%.zip...
rclone copyto "%ZIP_FILE%" "%REMOTE%:%DESTINATION_PATH%/%ZIP_FOLDER_NAME%.zip" ^
  --drive-root-folder-id "%ROOT_FOLDER_ID%" ^
  --progress ^
  --stats 30s ^
  --drive-chunk-size 64M ^
  --contimeout 30s ^
  --timeout 15m ^
  --retries 1 ^
  --low-level-retries 3 ^
  --log-file "%LOG_FILE%" ^
  --log-level DEBUG
set "ZIP_EXITCODE=%ERRORLEVEL%"
del /q "%ZIP_FILE%" 2>nul
rmdir "%ZIP_TEMP_DIR%" 2>nul
exit /b %ZIP_EXITCODE%

:ZIP_FAIL
echo ERROR: Could not create or verify %ZIP_FOLDER_NAME%.zip.
del /q "%ZIP_FILE%" 2>nul
rmdir "%ZIP_TEMP_DIR%" 2>nul
exit /b 1

:usage
echo Usage:
echo   %~nx0 "LOCAL_FOLDER" "GOOGLE_DRIVE_FOLDER_URL_OR_ID" [RCLONE_REMOTE] [DESTINATION_PATH]
echo.
echo Examples:
echo   %~nx0 "D:\RoboGRR\S6A67340005X" "https://drive.google.com/drive/folders/1PLmAKzagiYLUTX2Eqh8S_fDR1nE6tC5E"
echo   %~nx0 "D:\RoboGRR\S6A67340005X" "1PLmAKzagiYLUTX2Eqh8S_fDR1nE6tC5E" "gdrive"
echo.
echo Run without arguments to enter the local folder and Google Drive URL interactively.
echo Folder URLs may include /drive/u/2/folders/, a query, a trailing slash or a fragment.
echo The URL account index does not select an account; the rclone remote authorization does.
exit /b 0
