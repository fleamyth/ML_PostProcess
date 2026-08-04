@echo off
cd %~dp0..
set /p IP=<IP.dat
set tool_path=c:\DiagTool
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET TestItem=Headset_check_diable
SET Log=Headset_check_diable.log
SET log_path=%tool_path%\%log%
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat

set /a EXITCODE=255

rem del log file
del /f %log%
Tools\LANRS-Diags.exe /RD -ip %ip% -rf "%log_path%"

:Check
tools\LANRS-diags.exe /e -ip 192.168.1.51 -w -ex -f "c:\diagtool\audio-diags.exe -type 1 %1"
if %errorlevel% EQU 255 set /a EXITCODE=0 & goto Passlog
if %errorlevel% EQU 1 set /a EXITCODE=0 & goto Passlog

:Faillog
SET EXIT_PF=FAIL
GOTO backup

:Passlog
SET EXIT_PF=PASS

:backup
IF NOT EXIST %Log% GOTO END
copy %log% tools\%log%
Tools\LogTransfer-auto.exe -nl /de -
call setdate.bat
SET DEST=%TestItem%\%datepath%\%EXIT_PF%
IF NOT EXIST %MISC%\%DEST% MKDIR %MISC%\%DEST%
Copy %Log% %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%.log


:End
EXIT /B %EXITCODE%