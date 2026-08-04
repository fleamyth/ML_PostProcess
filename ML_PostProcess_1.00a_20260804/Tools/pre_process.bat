@echo off
setlocal EnableExtensions EnableDelayedExpansion

if "%~1" == "" goto :usage

set "PRE_PROCESS_BAT=%~1"
set "BACKUP_ROOT=%~2"
set "SOURCE_DIR=%~3"
set "TEST_NUMBER=%~4"
set "OP_FILE=%~5"

if defined TEST_NUMBER if "!TEST_NUMBER:~0,1!" == "#" set "TEST_NUMBER=!TEST_NUMBER:~1!"

if not exist "!PRE_PROCESS_BAT!" (
  echo ERROR: Pre-process batch file not found: "!PRE_PROCESS_BAT!"
  exit /b 2
)

rem Import the operator number from op.dat.
if not defined OP_FILE (
  for %%P in ("%CD%\op.dat" "%~dp0op.dat" "%~dp0..\op.dat") do (
    if not defined OP_FILE if exist "%%~P" set "OP_FILE=%%~P"
  )
)

if not defined OP_FILE (
  echo ERROR: op.dat not found. Pass its path as the 5th argument.
  exit /b 10
)

if not exist "!OP_FILE!" (
  echo ERROR: op.dat not found: "!OP_FILE!"
  exit /b 10
)

set "OPERATION="
set /p "OPERATION="<"!OP_FILE!"
if not defined OPERATION (
  echo ERROR: op.dat is empty: "!OP_FILE!"
  exit /b 11
)

echo Operator ^(from op.dat^): !OPERATION!

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
  echo Check adb devices and ensure the device state is device.
  exit /b 4
)

echo ADB serial: !SERIAL!

if not defined BACKUP_ROOT (
  for /f "usebackq delims=" %%D in (`powershell.exe -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"`) do set "BACKUP_ROOT=%%D\RoboGRR"
)

if not defined SOURCE_DIR (
  set "SOURCE_DIR=C:\Users\TEST\Desktop\logs\robocal_output"
)

set "RUN_MARKER=%TEMP%\robocal_pre_process_%RANDOM%_%RANDOM%.tmp"
type nul >"!RUN_MARKER!"
if errorlevel 1 (
  echo ERROR: Could not create run marker "!RUN_MARKER!".
  exit /b 5
)

echo Running pre-process: "!PRE_PROCESS_BAT!"
call "!PRE_PROCESS_BAT!"
set "PRE_PROCESS_EXITCODE=!ERRORLEVEL!"

set "SOURCE_LOG="
if exist "!SOURCE_DIR!" (
  for /f "usebackq delims=" %%F in (`powershell.exe -NoProfile -Command "$marker = (Get-Item -LiteralPath $env:RUN_MARKER).LastWriteTimeUtc; $latest = $null; foreach ($file in Get-ChildItem -LiteralPath $env:SOURCE_DIR -Filter 'log_file_*.log' -File) { if ($file.LastWriteTimeUtc -ge $marker -and ($null -eq $latest -or $file.LastWriteTimeUtc -gt $latest.LastWriteTimeUtc)) { $latest = $file } }; if ($null -ne $latest) { $latest.FullName }"`) do set "SOURCE_LOG=%%F"
)

del /q "!RUN_MARKER!" 2>nul

if not defined SOURCE_LOG (
  echo ERROR: No new pre-process log was found at "!SOURCE_DIR!".
  echo Pre-process exit code: !PRE_PROCESS_EXITCODE!
  exit /b 6
)

set "DESTINATION_DIR=!BACKUP_ROOT!\!SERIAL!\Pre"
for %%F in ("!SOURCE_LOG!") do set "LOG_NAME=%%~nxF"
set "DESTINATION_LOG=!DESTINATION_DIR!\!LOG_NAME!"

if exist "!DESTINATION_LOG!" (
  echo ERROR: Destination already exists: "!DESTINATION_LOG!"
  exit /b 7
)

mkdir "!DESTINATION_DIR!" 2>nul
if errorlevel 1 (
  echo ERROR: Could not create "!DESTINATION_DIR!".
  exit /b 8
)

copy /b /y "!SOURCE_LOG!" "!DESTINATION_LOG!" >nul
if errorlevel 1 (
  echo ERROR: Failed to copy "!SOURCE_LOG!".
  exit /b 9
)

echo Pre-process log backed up successfully.
echo Source:      !SOURCE_LOG!
echo Destination: !DESTINATION_LOG!
echo Pre-process exit code: !PRE_PROCESS_EXITCODE!
exit /b !PRE_PROCESS_EXITCODE!

:usage
echo Usage: %~nx0 PRE_PROCESS_BAT [BACKUP_ROOT] [SOURCE_DIR] [TEST_NUMBER] [OP_FILE]
echo.
echo PRE_PROCESS_BAT is the full path to the batch file that runs pre_process.
echo SERIAL is detected automatically from adb devices. Exactly one device
echo must be connected with the state device.
echo OP is imported from op.dat automatically. By default op.dat is searched in
echo the current directory, then this script folder, then its parent folder.
echo Pass OP_FILE to point at op.dat explicitly.
echo TEST_NUMBER is optional. If omitted, the #N folder level is not created.
echo If BACKUP_ROOT is omitted, Desktop\RoboGRR is used.
echo If SOURCE_DIR is omitted, this TEST user directory is used:
echo C:\Users\TEST\Desktop\logs\robocal_output
echo.
echo Example:
echo %~nx0 "C:\TestTools\run_pre_process.bat"
exit /b 1
