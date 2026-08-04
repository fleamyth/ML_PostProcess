@echo on
set log=device_check.log

findstr "!" %log%  > device_fail.log
if %errorlevel% neq 0 set /a exitcode=0 & goto passlog

:device_pass
setlocal enabledelayedexpansion
FOR /F "tokens=1 delims=" %%i IN (device_fail.log) DO (
find "%%i" device_pass.ini
if !errorlevel! neq 0 goto faillog
)

goto passlog

:faillog
echo 255
pause
exit /b 255

:passlog
echo 0
pause
exit /b 0