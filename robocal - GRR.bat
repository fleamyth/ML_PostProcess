@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "DESKTOP_DIR="
for /f "usebackq delims=" %%D in (`powershell.exe -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"`) do set "DESKTOP_DIR=%%D"
if not defined DESKTOP_DIR set "DESKTOP_DIR=%USERPROFILE%\Desktop"

set "SCRIPT_DIR=!DESKTOP_DIR!\glasses_scripts"
set "ROBOCAL_BAT="
set "OPERATION=OP1"
set "BACKUP_ROOT=!DESKTOP_DIR!\RoboGRR"
set "ROBOCAL_TESTER_TAG=/sdcard/robocal_grr_tester.txt"
set "NETWORK_BACKUP_ROOT="
set "MASTER_OUTPUT=!DESKTOP_DIR!\logs"
set "LOG_ARCHIVE_ROOT=D:\logs"
set "GOOGLE_DRIVE_URL=https://drive.google.com/drive/folders/1VuN9N7JXBBuHByXVgUjm1jEw18wSW_N6"
set "GOOGLE_DRIVE_UPLOAD_BAT=%~dp0ML_PreProcess_1.00a_20260716\Tools\upload_Folder_to_google_drive.bat"

if not "%~1" == "" set "ROBOCAL_BAT=%~1"
if not "%~2" == "" set "OPERATION=%~2"
if not "%~3" == "" set "BACKUP_ROOT=%~3"
if not "%~4" == "" set "MASTER_OUTPUT=%~4"

if not defined ROBOCAL_BAT (
  call :SELECT_ROBOCAL_BAT
  if errorlevel 1 exit /b !ERRORLEVEL!
)

if "%~2" == "" (
  set "OPERATION_INPUT="
  set /p "OPERATION_INPUT=Enter operation [OP1]: "
  if defined OPERATION_INPUT set "OPERATION=!OPERATION_INPUT!"
)

echo Operation: !OPERATION!

if not exist "!ROBOCAL_BAT!" (
  echo ERROR: RoboCal batch file not found: "!ROBOCAL_BAT!"
  exit /b 2
)

set "ADB_DEVICES_FILE=%TEMP%\robocal_adb_devices_%RANDOM%_%RANDOM%.tmp"
call adb devices >"!ADB_DEVICES_FILE!"
if errorlevel 1 (
  echo ERROR: Failed to run adb devices.
  del /q "!ADB_DEVICES_FILE!" 2>nul
  exit /b 3
)

set "SERIAL="
set /a DEVICE_COUNT=0
for /f "usebackq skip=1 tokens=1,2" %%A in ("!ADB_DEVICES_FILE!") do (
  if "%%B" == "device" (
    set /a DEVICE_COUNT+=1
    set "SERIAL=%%A"
  )
)
del /q "!ADB_DEVICES_FILE!" 2>nul

if not "!DEVICE_COUNT!" == "1" (
  echo ERROR: Expected exactly one connected ADB device, found !DEVICE_COUNT!.
  exit /b 4
)

set "ROBOCAL_TESTER="
for /f "usebackq delims=" %%H in (`adb shell "cat !ROBOCAL_TESTER_TAG!" 2^>nul`) do set "ROBOCAL_TESTER=%%H"
if not defined ROBOCAL_TESTER (
  echo ERROR: RoboCal tester tag was not found on the glasses.
  echo Run pre_process - GRR.bat first and select the RoboCal tester.
  exit /b 5
)
if /i not "!ROBOCAL_TESTER!" == "RBCIN14" if /i not "!ROBOCAL_TESTER!" == "L89VJIQ" (
  echo ERROR: Invalid RoboCal tester tag "!ROBOCAL_TESTER!".
  echo Run pre_process - GRR.bat again to select a valid tester.
  exit /b 5
)

echo %COMPUTERNAME% | findstr /i /c:"!ROBOCAL_TESTER!" >nul
if errorlevel 1 (
  echo ERROR: Wrong RoboCal tester.
  echo This GRR run is assigned to !ROBOCAL_TESTER!, but this computer is %COMPUTERNAME%.
  echo Move the glasses to tester !ROBOCAL_TESTER! and run RoboCal again.
  exit /b 5
)
set "NETWORK_BACKUP_ROOT=\\RBCIN14\D\RoboGRR_!ROBOCAL_TESTER!"

set "LOG_IDENTIFIER="
for /f "usebackq delims=" %%H in (`adb shell getprop ro.serialno 2^>nul`) do set "LOG_IDENTIFIER=%%H"
if not defined LOG_IDENTIFIER set "LOG_IDENTIFIER=!SERIAL!"

echo ADB serial:     !SERIAL!
echo Log identifier: !LOG_IDENTIFIER!
echo RoboCal tester: !ROBOCAL_TESTER!

if not exist "!MASTER_OUTPUT!" (
  echo ERROR: RoboCal master output directory not found: "!MASTER_OUTPUT!"
  exit /b 5
)

set "RUN_MARKER=%TEMP%\robocal_grr_%RANDOM%_%RANDOM%.tmp"
type nul >"!RUN_MARKER!"
if errorlevel 1 (
  echo ERROR: Could not create run marker "!RUN_MARKER!".
  exit /b 6
)

echo Running RoboCal: "!ROBOCAL_BAT!"
call "!ROBOCAL_BAT!"
set "ROBOCAL_EXITCODE=!ERRORLEVEL!"

set "DESTINATION_DIR=!BACKUP_ROOT!\!SERIAL!\!OPERATION!\Robocal"
if not exist "!DESTINATION_DIR!\" mkdir "!DESTINATION_DIR!" 2>nul
if not exist "!DESTINATION_DIR!\" (
  echo ERROR: Could not create "!DESTINATION_DIR!".
  del /q "!RUN_MARKER!" 2>nul
  exit /b 7
)

set "ROBOCAL_SOURCE=!MASTER_OUTPUT!\!LOG_IDENTIFIER!"
set "COPY_COUNT=0"
set "COPY_COUNT_FILE=%TEMP%\robocal_grr_count_%RANDOM%_%RANDOM%.tmp"
powershell.exe -NoProfile -Command "$marker = (Get-Item -LiteralPath $env:RUN_MARKER).LastWriteTimeUtc; $source = $env:ROBOCAL_SOURCE; $destination = $env:DESTINATION_DIR; $count = 0; if (Test-Path -LiteralPath $source) { foreach ($file in Get-ChildItem -LiteralPath $source -Recurse -File) { if ($file.LastWriteTimeUtc -ge $marker) { $relative = $file.FullName.Substring($source.Length).TrimStart('\'); $target = Join-Path $destination $relative; $parent = Split-Path -Parent $target; New-Item -ItemType Directory -Path $parent -Force | Out-Null; Copy-Item -LiteralPath $file.FullName -Destination $target -Force; $count++ } } }; $logSource = Join-Path $env:MASTER_OUTPUT 'robocal_output'; if (Test-Path -LiteralPath $logSource) { foreach ($file in Get-ChildItem -LiteralPath $logSource -File) { if (($file.Name -like 'log_file_*.txt' -or $file.Name -like 'log_file_*.log') -and $file.LastWriteTimeUtc -ge $marker) { Copy-Item -LiteralPath $file.FullName -Destination $destination -Force; $count++ } } }; Set-Content -LiteralPath $env:COPY_COUNT_FILE -Value $count -Encoding Ascii"
set "COPY_EXITCODE=!ERRORLEVEL!"

if not "!COPY_EXITCODE!" == "0" (
  echo ERROR: Failed to back up RoboCal data.
  del /q "!RUN_MARKER!" "!COPY_COUNT_FILE!" 2>nul
  exit /b 8
)

if exist "!COPY_COUNT_FILE!" set /p "COPY_COUNT="<"!COPY_COUNT_FILE!"

del /q "!RUN_MARKER!" "!COPY_COUNT_FILE!" 2>nul

if "!COPY_COUNT!" == "0" (
  echo ERROR: No new RoboCal data was found under "!MASTER_OUTPUT!".
  echo RoboCal exit code: !ROBOCAL_EXITCODE!
  exit /b 9
)

set "NETWORK_DESTINATION_DIR=!NETWORK_BACKUP_ROOT!\!SERIAL!\!OPERATION!\Robocal"
if not exist "!NETWORK_DESTINATION_DIR!\" mkdir "!NETWORK_DESTINATION_DIR!" 2>nul
if not exist "!NETWORK_DESTINATION_DIR!\" (
  echo ERROR: Could not create network backup directory "!NETWORK_DESTINATION_DIR!".
  exit /b 10
)

xcopy "!DESTINATION_DIR!\*" "!NETWORK_DESTINATION_DIR!\" /E /I /Y /Q >nul
if errorlevel 1 (
  echo ERROR: Failed to back up RoboCal data to "!NETWORK_DESTINATION_DIR!".
  exit /b 10
)

set "LOG_ARCHIVE_DIR=!LOG_ARCHIVE_ROOT!\!LOG_IDENTIFIER!"
if exist "!ROBOCAL_SOURCE!\" (
  if not exist "!LOG_ARCHIVE_DIR!\" mkdir "!LOG_ARCHIVE_DIR!" 2>nul
  if not exist "!LOG_ARCHIVE_DIR!\" (
    echo ERROR: Could not create log archive directory "!LOG_ARCHIVE_DIR!".
    exit /b 11
  )

  robocopy "!ROBOCAL_SOURCE!" "!LOG_ARCHIVE_DIR!" /E /MOVE /R:2 /W:1 /NFL /NDL /NJH /NJS /NP >nul
  set "ARCHIVE_EXITCODE=!ERRORLEVEL!"
  if !ARCHIVE_EXITCODE! GEQ 8 (
    echo ERROR: Failed to move desktop logs to "!LOG_ARCHIVE_DIR!".
    exit /b 11
  )
  rmdir "!ROBOCAL_SOURCE!" 2>nul
  if exist "!ROBOCAL_SOURCE!\" (
    echo ERROR: Some desktop logs could not be moved to "!LOG_ARCHIVE_DIR!".
    exit /b 11
  )
)

set "GOOGLE_DRIVE_STATUS=Skipped"
set "UPLOAD_TO_GOOGLE_DRIVE="
set /p "UPLOAD_TO_GOOGLE_DRIVE=Upload GRR data to Google Drive? [y/N]: "
if /i "!UPLOAD_TO_GOOGLE_DRIVE!" == "Y" set "UPLOAD_TO_GOOGLE_DRIVE=YES"
if /i "!UPLOAD_TO_GOOGLE_DRIVE!" == "YES" (
  call "!GOOGLE_DRIVE_UPLOAD_BAT!" "!BACKUP_ROOT!\!SERIAL!" "!GOOGLE_DRIVE_URL!"
  if errorlevel 1 (
    echo ERROR: Failed to upload RoboCal data to Google Drive.
    exit /b 12
  )
  set "GOOGLE_DRIVE_STATUS=Uploaded to !GOOGLE_DRIVE_URL!"
)

echo RoboCal data backed up successfully.
echo Source:      !MASTER_OUTPUT!
echo Local:       !DESTINATION_DIR!
echo Network:     !NETWORK_DESTINATION_DIR!
echo Google Drive: !GOOGLE_DRIVE_STATUS!
if exist "!LOG_ARCHIVE_DIR!\" echo Log archive: !LOG_ARCHIVE_DIR!
echo Files copied: !COPY_COUNT!
echo RoboCal exit code: !ROBOCAL_EXITCODE!
exit /b !ROBOCAL_EXITCODE!

:SELECT_ROBOCAL_BAT
if not exist "!SCRIPT_DIR!\" (
  echo ERROR: Glasses scripts directory not found: "!SCRIPT_DIR!"
  exit /b 2
)

set /a SCRIPT_COUNT=0
echo Available batch files in "!SCRIPT_DIR!":
echo.
for /f "delims=" %%F in ('dir /b /s /a-d "!SCRIPT_DIR!\*.bat" 2^>nul') do (
  set /a SCRIPT_COUNT+=1
  set "SCRIPT_!SCRIPT_COUNT!=%%F"
  set "SCRIPT_NAME=%%F"
  set "SCRIPT_NAME=!SCRIPT_NAME:%SCRIPT_DIR%\=!"
  echo   !SCRIPT_COUNT!. !SCRIPT_NAME!
)

if "!SCRIPT_COUNT!" == "0" (
  echo ERROR: No batch files were found in "!SCRIPT_DIR!".
  exit /b 2
)

echo.
echo Total batch files: !SCRIPT_COUNT!

:SELECT_ROBOCAL_SCRIPT
set "SCRIPT_SELECTION="
set /p "SCRIPT_SELECTION=Select a batch file [1-!SCRIPT_COUNT!]: "
if not defined SCRIPT_SELECTION goto SELECT_ROBOCAL_SCRIPT
for /f "delims=0123456789" %%A in ("!SCRIPT_SELECTION!") do goto INVALID_ROBOCAL_SCRIPT_SELECTION
if !SCRIPT_SELECTION! LSS 1 goto INVALID_ROBOCAL_SCRIPT_SELECTION
if !SCRIPT_SELECTION! GTR !SCRIPT_COUNT! goto INVALID_ROBOCAL_SCRIPT_SELECTION
for %%N in (!SCRIPT_SELECTION!) do set "ROBOCAL_BAT=!SCRIPT_%%N!"
echo Selected: "!ROBOCAL_BAT!"
echo.
exit /b 0

:INVALID_ROBOCAL_SCRIPT_SELECTION
echo Invalid selection. Enter a number from 1 to !SCRIPT_COUNT!.
goto SELECT_ROBOCAL_SCRIPT
