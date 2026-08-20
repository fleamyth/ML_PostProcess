@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "SCRIPT_DIR=C:\Users\TEST\Desktop\glasses_scripts"
set "PRE_PROCESS_BAT="
set "OPERATION=OP1"
set "BACKUP_ROOT=C:\Users\TEST\Desktop\RoboGRR"
set "ROBOCAL_TESTER="
set "ROBOCAL_TESTER_TAG=/sdcard/robocal_grr_tester.txt"
set "NETWORK_BACKUP_ROOT="
set "SOURCE_DIR=C:\Users\TEST\Desktop\logs\robocal_output"
set "GOOGLE_DRIVE_URL=https://drive.google.com/drive/folders/1VuN9N7JXBBuHByXVgUjm1jEw18wSW_N6"
set "GOOGLE_DRIVE_UPLOAD_BAT=%~dp0ML_PreProcess_1.00a_20260716\Tools\upload_Folder_to_google_drive.bat"

if not "%~1" == "" set "PRE_PROCESS_BAT=%~1"
if not "%~2" == "" set "OPERATION=%~2"
if not "%~3" == "" set "BACKUP_ROOT=%~3"
if not "%~4" == "" set "SOURCE_DIR=%~4"
if not "%~5" == "" set "ROBOCAL_TESTER=%~5"

if not defined PRE_PROCESS_BAT (
  call :SELECT_PRE_PROCESS_BAT
  if errorlevel 1 exit /b !ERRORLEVEL!
)

if "%~2" == "" (
  set "OPERATION_INPUT="
  set /p "OPERATION_INPUT=Enter operation [OP1]: "
  if defined OPERATION_INPUT set "OPERATION=!OPERATION_INPUT!"
)

if not defined ROBOCAL_TESTER (
  call :SELECT_ROBOCAL_TESTER
  if errorlevel 1 exit /b !ERRORLEVEL!
)

if /i not "!ROBOCAL_TESTER!" == "RBCIN14" if /i not "!ROBOCAL_TESTER!" == "L89VJIQ" (
  echo ERROR: Invalid RoboCal tester "!ROBOCAL_TESTER!". Use RBCIN14 or L89VJIQ.
  exit /b 2
)
set "NETWORK_BACKUP_ROOT=\\RBCIN14\D\RoboGRR_!ROBOCAL_TESTER!"

echo Operation: !OPERATION!
echo RoboCal tester: !ROBOCAL_TESTER!

if not exist "!PRE_PROCESS_BAT!" (
  echo ERROR: Pre-process batch file not found: "!PRE_PROCESS_BAT!"
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
  echo Check adb devices and ensure the device state is device.
  exit /b 4
)

echo ADB serial: !SERIAL!

adb shell "echo !ROBOCAL_TESTER! > !ROBOCAL_TESTER_TAG!"
if errorlevel 1 (
  echo ERROR: Failed to write RoboCal tester tag to !ROBOCAL_TESTER_TAG!.
  exit /b 5
)

set "SAVED_ROBOCAL_TESTER="
for /f "usebackq delims=" %%H in (`adb shell "cat !ROBOCAL_TESTER_TAG!" 2^>nul`) do set "SAVED_ROBOCAL_TESTER=%%H"
if /i not "!SAVED_ROBOCAL_TESTER!" == "!ROBOCAL_TESTER!" (
  echo ERROR: RoboCal tester tag verification failed.
  exit /b 5
)

set "SOURCE_LOG_BEFORE="
if exist "!SOURCE_DIR!" (
  for /f "delims=" %%F in ('dir /b /a-d /o-d "!SOURCE_DIR!\log_file_*.log" 2^>nul') do if not defined SOURCE_LOG_BEFORE set "SOURCE_LOG_BEFORE=%%F"
)

echo Running pre-process: "!PRE_PROCESS_BAT!"
call "!PRE_PROCESS_BAT!"
set "PRE_PROCESS_EXITCODE=!ERRORLEVEL!"

adb root
adb shell aflags disable com.android.microxr.flags.enable_wifi_connection_access_point
adb shell setprop persist.microxr.internetaccess.disable_wifi_control true
adb reboot

set "SOURCE_LOG="
if exist "!SOURCE_DIR!" (
  for /f "delims=" %%F in ('dir /b /a-d /o-d "!SOURCE_DIR!\log_file_*.log" 2^>nul') do if not defined SOURCE_LOG set "SOURCE_LOG=%%F"
)

if /i "!SOURCE_LOG!" == "!SOURCE_LOG_BEFORE!" set "SOURCE_LOG="

if not defined SOURCE_LOG (
  echo ERROR: No new pre-process log was found at "!SOURCE_DIR!".
  echo Pre-process exit code: !PRE_PROCESS_EXITCODE!
  exit /b 6
)

set "DESTINATION_DIR=!BACKUP_ROOT!\!SERIAL!\!OPERATION!\Pre"
set "LOG_NAME=!SOURCE_LOG!"
set "SOURCE_LOG=!SOURCE_DIR!\!SOURCE_LOG!"
set "DESTINATION_LOG=!DESTINATION_DIR!\!LOG_NAME!"

if exist "!DESTINATION_LOG!" (
  echo ERROR: Destination already exists: "!DESTINATION_LOG!"
  exit /b 7
)

if not exist "!DESTINATION_DIR!\" mkdir "!DESTINATION_DIR!" 2>nul
if not exist "!DESTINATION_DIR!\" (
  echo ERROR: Could not create "!DESTINATION_DIR!".
  exit /b 8
)

copy /b /y "!SOURCE_LOG!" "!DESTINATION_LOG!" >nul
if errorlevel 1 (
  echo ERROR: Failed to copy "!SOURCE_LOG!".
  exit /b 9
)

set "NETWORK_DESTINATION_DIR=!NETWORK_BACKUP_ROOT!\!SERIAL!\!OPERATION!\Pre"
set "NETWORK_DESTINATION_LOG=!NETWORK_DESTINATION_DIR!\!LOG_NAME!"
if not exist "!NETWORK_DESTINATION_DIR!\" mkdir "!NETWORK_DESTINATION_DIR!" 2>nul
if not exist "!NETWORK_DESTINATION_DIR!\" (
  echo ERROR: Could not create network backup directory "!NETWORK_DESTINATION_DIR!".
  exit /b 10
)

copy /b /y "!SOURCE_LOG!" "!NETWORK_DESTINATION_LOG!" >nul
if errorlevel 1 (
  echo ERROR: Failed to copy pre-process log to "!NETWORK_DESTINATION_LOG!".
  exit /b 10
)

call "!GOOGLE_DRIVE_UPLOAD_BAT!" "!BACKUP_ROOT!\!SERIAL!" "!GOOGLE_DRIVE_URL!"
if errorlevel 1 (
  echo ERROR: Failed to upload pre-process data to Google Drive.
  exit /b 11
)

echo Pre-process log backed up successfully.
echo Source:      !SOURCE_LOG!
echo Local:       !DESTINATION_LOG!
echo Network:     !NETWORK_DESTINATION_LOG!
echo Google Drive: !GOOGLE_DRIVE_URL!
echo Pre-process exit code: !PRE_PROCESS_EXITCODE!
exit /b !PRE_PROCESS_EXITCODE!

:SELECT_ROBOCAL_TESTER
echo.
echo Select the RoboCal tester for this GRR run:
echo   1. RBCIN14
echo   2. L89VJIQ
:SELECT_ROBOCAL_TESTER_RETRY
set "ROBOCAL_TESTER_SELECTION="
set /p "ROBOCAL_TESTER_SELECTION=Select tester [1-2]: "
if "!ROBOCAL_TESTER_SELECTION!" == "1" (
  set "ROBOCAL_TESTER=RBCIN14"
  exit /b 0
)
if "!ROBOCAL_TESTER_SELECTION!" == "2" (
  set "ROBOCAL_TESTER=L89VJIQ"
  exit /b 0
)
echo Invalid selection. Enter 1 or 2.
goto SELECT_ROBOCAL_TESTER_RETRY

:SELECT_PRE_PROCESS_BAT
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

:SELECT_SCRIPT
set "SCRIPT_SELECTION="
set /p "SCRIPT_SELECTION=Select a batch file [1-!SCRIPT_COUNT!]: "
if not defined SCRIPT_SELECTION goto SELECT_SCRIPT
for /f "delims=0123456789" %%A in ("!SCRIPT_SELECTION!") do goto INVALID_SCRIPT_SELECTION
if !SCRIPT_SELECTION! LSS 1 goto INVALID_SCRIPT_SELECTION
if !SCRIPT_SELECTION! GTR !SCRIPT_COUNT! goto INVALID_SCRIPT_SELECTION
for %%N in (!SCRIPT_SELECTION!) do set "PRE_PROCESS_BAT=!SCRIPT_%%N!"
echo Selected: "!PRE_PROCESS_BAT!"
echo.
exit /b 0

:INVALID_SCRIPT_SELECTION
echo Invalid selection. Enter a number from 1 to !SCRIPT_COUNT!.
goto SELECT_SCRIPT

:usage
echo Usage: %~nx0 [PRE_PROCESS_BAT] [OP] [BACKUP_ROOT] [SOURCE_DIR] [ROBOCAL_TESTER]
echo.
echo Run without arguments to select a batch file and OP interactively.
echo The batch-file menu recursively scans:
echo C:\Users\TEST\Desktop\glasses_scripts
echo PRE_PROCESS_BAT optionally overrides the configured pre-process batch file.
echo SERIAL is detected automatically from adb devices. Exactly one device
echo must be connected with the state device.
echo If BACKUP_ROOT is omitted, Desktop\RoboGRR is used.
echo If SOURCE_DIR is omitted, this TEST user directory is used:
echo C:\Users\TEST\Desktop\logs\robocal_output
echo ROBOCAL_TESTER must be RBCIN14 or L89VJIQ. If omitted, it is selected interactively.
echo The selection is saved to /sdcard/robocal_grr_tester.txt on the glasses.
echo Network backup uses \\RBCIN14\D\RoboGRR_ROBOCAL_TESTER.
echo.
echo Example:
echo %~nx0
echo %~nx0 "C:\TestTools\run_pre_process.bat" OP1
exit /b 1
