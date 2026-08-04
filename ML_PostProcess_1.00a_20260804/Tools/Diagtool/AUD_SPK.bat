@echo on
cd %~dp0


audio-diag.exe /svol 70

Delay-diags.exe /s 1

audio-diags.exe /TSP

if %errorlevel% equ 0 goto pass


:fail
exit /b 255


:pass
exit /b 0
