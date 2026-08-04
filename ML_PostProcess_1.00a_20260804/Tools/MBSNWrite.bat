@echo off
cd %~dp0..
set /p IP=<IP.dat
set tool_path=c:\DiagTool
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET TestItem=MBSNWrite
SET Log=MBSNWrite.log
SET log_path=%tool_path%\%log%
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat

set /a EXITCODE=1

rem del log file
del /f %log%
Tools\LANRS-Diags.exe /RD -ip %ip% -rf "%log_path%"

:run
rem set mb sn
set MBSN=%SN%

rem mbsn write
Tools\LANRS-diags.exe /e -ip %ip% -w -ex -f "cmd.exe /c C:\Diagtool\SMBIOS\ProgramMBSerialNumber.cmd -MBSerialNumber %MBSN% >%log_path%"
set /a exitcode=%errorlevel%

rem get log from server
Tools\LANRS-diags.exe /Q -ip %ip% -rf "%log_path%"
if not exist %log% exit /b 1

if %exitcode% equ 0 goto passlog

set /a exitcode=1

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