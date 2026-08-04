@echo on
cd %~dp0

USB3164-diags.exe -high /speed
Delay-diags.exe /s 2
USB3164-diags.exe -high /speed

if %errorlevel% equ 0 goto PASS
goto FAIL

:PASS
taskkill /im USB3164-diags.exe
exit /b 0

:FAIL
taskkill /im USB3164-diags.exe
exit /b 255