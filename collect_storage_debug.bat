@echo off
setlocal EnableExtensions

set "ADB=adb"
if not "%~1"=="" set "ADB=adb -s %~1"

where adb >nul 2>&1
if errorlevel 1 (
    echo [ERROR] adb.exe was not found in PATH.
    exit /b 1
)

for /f %%I in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "TIMESTAMP=%%I"
set "OUTPUT_DIR=%CD%\storage_debug_%TIMESTAMP%"
mkdir "%OUTPUT_DIR%" >nul 2>&1
set "SUMMARY=%OUTPUT_DIR%\summary.txt"

call :Log "Storage debug collection started"
call :Log "Output directory: %OUTPUT_DIR%"
if not "%~1"=="" call :Log "Target device: %~1"

call :Log "Recording connected devices"
adb devices -l >"%OUTPUT_DIR%\adb_devices.txt" 2>&1

call :Log "Step 1: Restarting adbd as root"
%ADB% root >"%OUTPUT_DIR%\adb_root.txt" 2>&1
%ADB% get-state >"%OUTPUT_DIR%\adb_state_after_root.txt" 2>&1

call :Log "Step 1: Checking /data and FUSE mount status"
%ADB% shell "mount | grep /data" >"%OUTPUT_DIR%\mount_data.txt" 2>&1
%ADB% shell "mount | grep -E 'emulated|fuse'" >"%OUTPUT_DIR%\mount_fuse.txt" 2>&1

call :Log "Step 2: Checking raw storage access through /data/media/0"
%ADB% shell ls -la /data/media/0 >"%OUTPUT_DIR%\data_media_0.txt" 2>&1

call :Log "Step 3: Checking credential-encrypted user storage"
%ADB% shell ls -la /data/user/0 >"%OUTPUT_DIR%\data_user_0.txt" 2>&1

call :Log "Collecting storage properties and service status"
%ADB% shell getprop >"%OUTPUT_DIR%\getprop.txt" 2>&1
%ADB% shell dumpsys mount >"%OUTPUT_DIR%\dumpsys_mount.txt" 2>&1
%ADB% shell dumpsys user >"%OUTPUT_DIR%\dumpsys_user.txt" 2>&1

call :Log "Step 4: Collecting logcat"
%ADB% logcat -b all -d >"%OUTPUT_DIR%\logcat.txt" 2>&1
if errorlevel 1 call :Log "WARNING: logcat collection failed; see logcat.txt"

call :Log "Step 4: Collecting bugreport; this may take several minutes"
%ADB% bugreport "%OUTPUT_DIR%\bugreport.zip" >"%OUTPUT_DIR%\bugreport_command.txt" 2>&1
if errorlevel 1 (
    call :Log "WARNING: bugreport collection failed; see bugreport_command.txt"
) else (
    call :Log "Bugreport collection completed"
)

call :Log "Collection finished. Attach this entire directory to the bug."
echo.
echo Debug files saved to:
echo %OUTPUT_DIR%
exit /b 0

:Log
echo [%DATE% %TIME%] %~1
echo [%DATE% %TIME%] %~1>>"%SUMMARY%"
exit /b 0