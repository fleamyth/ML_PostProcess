@echo on
cd %~dp0



IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat
set /a exitcode=255

Delay-Diags.exe /s 1
rem diagtool\Display32-Diags.exe /e 1 0
diagtool\Display32-Diags.exe /E3 2 1 0
Delay-Diags.exe /s 1

Btn-diag.exe /btns TypeC_display.ini                                                                                          



if %errorlevel% equ 1 goto pass
goto fail
:switch


rem Delay-Diags.exe /s 5



:fail
rem diagtool\Display32-Diags.exe /S 1
rem Delay-Diags.exe /s 3
rem Screen-diag.exe -nl -enter /spt "%1"
exit /b 255

:pass
rem diagtool\Display32-Diags.exe /S 1
rem Delay-Diags.exe /s 5
rem Screen-diag.exe -nl -enter /spt "unplug.png"
exit /b 0

