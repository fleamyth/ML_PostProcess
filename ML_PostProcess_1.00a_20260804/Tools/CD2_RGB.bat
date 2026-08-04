@echo on
cd %~dp0

set /p IP=<IP.dat
set tool_path=C:\diagTool
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET Log=Display_%1.log
SET log_path=%tool_path%\%log%
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat
set /a exitcode=255
SET TestItem=Display_CD2_RGB
if exist CD2_RGB.log del CD2_RGB.log

Screen-diag.exe -nl -enter /spt "CD2.png"
echo %errorlevel%

Delay-Diags.exe /s 1


:switch
LANRS-Diags.exe /e -ip 192.168.1.51 -e -f "c:\diagtool\Display32-Diags.exe /S 0"
echo %errorlevel%

Delay-Diags.exe /s 10
rem if %errorlevel% equ 255 goto fail


:TEST
LANRS-Diags.exe /e -ip 192.168.1.51 -e -f "c:\diagtool\CD2_RGB.cmd"
Delay-Diags.exe /s 10
LANRS-diags.exe /Q -ip 192.168.1.51 -rf "%tool_path%\CD2_RGB.log"

find "pass" CD2_RGB.log


if %errorlevel% equ 0 goto pass


:fail
LANRS-Diags.exe /e -ip 192.168.1.51 -f "c:\diagtool\Display32-Diags.exe /S 1
Delay-Diags.exe /s 5
exit /b 255

:pass
LANRS-Diags.exe /e -ip 192.168.1.51 -f "c:\diagtool\Display32-Diags.exe /S 1
Delay-Diags.exe /s 5
exit /b 0

