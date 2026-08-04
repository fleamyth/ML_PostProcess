@echo off
cd %~dp0..
set /p IP=<IP.dat
set tool_path=c:\DiagTool
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET TestItem=CPUMspd
SET Log=CPUMspd.log
SET log_path=%tool_path%\%log%
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat

del %log%
Tools\LANRS-diags.exe /rd -ip %ip% -rf "%log_path%"


:CPUMspd
set /p CPU_FRQ_Min=<CPU_FRQ_Min.dat
set /p CPU_FRQ_Max=<CPU_FRQ_Max.dat

Tools\LANRS-diags.exe /e -ip %ip% -w -ex -f "cmd.exe /c c:\diagtool\CPU-diags -nl /mspd %CPU_FRQ_Min% %CPU_FRQ_Max% >%log_path%"
set /a exitcode=%errorlevel%

rem get log file from DUT
Tools\LANRS-diags.exe /Q -ip %ip% -rf "%log_path%"

if %exitcode% equ 0 goto Passlog

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