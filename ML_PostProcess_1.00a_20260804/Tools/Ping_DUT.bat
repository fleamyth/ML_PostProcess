@echo off
setlocal EnableExtensions

rem Clean previous DeviceBridge log files.
if exist "C:\DeviceBridgeLogs\" (
    del /f /q "C:\DeviceBridgeLogs\*" 2>nul
)

rem Change to the parent directory of this batch file.
cd /d "%~dp0.."
if errorlevel 1 (
    echo ERROR: Failed to change directory.
    exit /b 1
)

rem Read device IP.
if not exist "IP.dat" (
    echo ERROR: IP.dat does not exist.
    exit /b 2
)
set /p "IP="<"IP.dat"

set "tool_path=C:\DiagTool"
set "MISC=C:\MISClog\Debug"

if exist "MISClog.dat" (
    set /p "MISC="<"MISClog.dat"
)

echo Waiting for ADB device...
adb wait-for-device

rem Save the exit code immediately.
set "exitcode=%ERRORLEVEL%"

if not "%exitcode%"=="0" (
    echo ERROR: adb wait-for-device failed.
    echo Exit code: %exitcode%
    goto :End
)

echo ADB device connected successfully.
echo Exit code: %exitcode%

:End
endlocal & exit /b %exitcode%