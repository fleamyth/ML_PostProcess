@echo on
cd %~dp0

Diagtool\audio-diags.exe /chau -setau "Headphones"
Delay-diags.exe /s 2
taskkill /im rundll32.exe
Delay-diags.exe /s 1
taskkill /im rundll32.exe
Delay-diags.exe /s 1
taskkill /im rundll32.exe
Delay-diags.exe /s 1
taskkill /im rundll32.exe
Delay-diags.exe /s 1
taskkill /im rundll32.exe

rem if %errorlevel% equ 0 goto PASS

:FAIL
rem exit /b 255

:PASS
exit /b 0



