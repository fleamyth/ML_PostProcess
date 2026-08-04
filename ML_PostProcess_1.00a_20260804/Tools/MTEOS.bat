@echo off
cd %~dp0..
set /p IP=<IP.dat
set tool_path=c:\DiagTool
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET TestItem=MTEOS
SET Log=MTEOS.log
SET log_path=%tool_path%\%log%
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat

set /a EXITCODE=1

:run
rem del log file
del /f %log%
Tools\LANRS-Diags.exe /RD -ip %ip% -rf "%log_path%"
del /f mteos_ver.log

rem run mteos version
Tools\LANRS-diags.exe /e -ip %ip% -w -ex -f "c:\diagtool\mteos_dut.bat"
rem Tools\LANRS-diags.exe /e -ip %ip% -w -ex -f "cmd.exe /c dir c:\oemnh.mteos* > %log_path%"


rem get log from server
Tools\LANRS-diags.exe /Q -ip %ip% -rf "%log_path%"
if not exist MTEOS.log goto faillog

tools\PT-diags.exe /find MTEOS.log "mteos" > mteos_ver.log


:type1
IF NOT EXIST MTEOS1.dat GOTO TYPE2
SET /p MTEOS=<MTEOS1.dat
find /c "%MTEOS%" mteos_ver.log
IF %ERRORLEVEL% EQU 0 set /a EXITCODE=0 & goto Passlog

:type2
IF NOT EXIST MTEOS2.dat GOTO TYPE3
SET /p MTEOS=<MTEOS2.dat
find /c "%MTEOS%" mteos_ver.log
IF %ERRORLEVEL% EQU 0 set /a EXITCODE=0 & goto Passlog

:type3
IF NOT EXIST MTEOS3.dat GOTO TYPE4
SET /p MTEOS=<MTEOS3.dat
find /c "%MTEOS%" mteos_ver.log
IF %ERRORLEVEL% EQU 0 set /a EXITCODE=0 & goto Passlog

:type4
IF NOT EXIST MTEOS4.dat GOTO end
SET /p MTEOS=<MTEOS4.dat
find /c "%MTEOS%" mteos_ver.log
IF %ERRORLEVEL% EQU 0 set /a EXITCODE=0 & goto Passlog

:Faillog
SET EXIT_PF=FAIL
GOTO backup

:Passlog
SET EXIT_PF=PASS
set /a EXITCODE=0

:backup
IF NOT EXIST %Log% GOTO END
Tools\LogTransfer-auto.exe -nl /de -
call setdate.bat
SET DEST=%TestItem%\%datepath%\%EXIT_PF%
IF NOT EXIST %MISC%\%DEST% MKDIR %MISC%\%DEST%
Copy %Log% %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%.log

:End
EXIT /B %EXITCODE%
