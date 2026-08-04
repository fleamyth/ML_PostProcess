@echo on
cd %~dp0


rem set tool_path=C:\diagTool

rem SET Log=Display_%1.log
rem SET log_path=%tool_path%\%log%
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat
set /a exitcode=255

Screen-diag.exe -nl -enter /spt "%1"

Delay-Diags.exe /s 1


:switch
diagtool\Display32-Diags.exe /S 0

Delay-Diags.exe /s 5


:TEST
diagtool\Video-diags.exe -nonum -noscr g b w h m n /rgbnum
if %errorlevel% equ 0 goto pass


:fail
diagtool\Display32-Diags.exe /S 1
Delay-Diags.exe /s 3
Screen-diag.exe -nl -enter /spt "%1"
exit /b 255

:pass
diagtool\Display32-Diags.exe /S 1
Delay-Diags.exe /s 5
Screen-diag.exe -nl -enter /spt "unplug.png"
exit /b 0

