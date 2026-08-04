@echo off
cd %~dp0..
set /p IP=<IP.dat
set tool_path=c:\DiagTool
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET TestItem=FAN_%1
SET Log=FAN_%1.log
SET log_path=%tool_path%\%log%
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat

set /a exitcode=255

rem del log
del %log%
Tools\LANRS-diags.exe /rd -ip %ip% -rf "%log_path%"

:Thermal
Tools\LANRS-diags.exe /e -ip %ip% -w -ex -f "cmd.exe /c c:\diagtool\Smonitor\SmonitorUAP.exe %2 %3 >%log_path%"

rem get log file from DUT
Tools\LANRS-diags.exe /Q -ip %ip% -rf "%log_path%"

rem check log
tools\pt-diags /find %log% "Pass"
if %errorlevel% neq 0 goto faillog

goto Passlog

:Faillog
SET EXIT_PF=FAIL
GOTO backup

:Passlog
SET EXITCODE=0
SET EXIT_PF=PASS

:backup
IF NOT EXIST %Log% GOTO END
Tools\LogTransfer-auto.exe -nl /de -
call setdate.bat
SET DEST=%TestItem%\%datepath%\%EXIT_PF%
IF NOT EXIST %MISC%\%DEST% MKDIR %MISC%\%DEST%
Copy %Log% %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%.log


:End
EXIT /B %EXITCODE%