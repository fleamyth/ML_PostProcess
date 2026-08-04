@echo off
cd %~dp0..
set /p IP=<IP.dat
set tool_path=c:\DiagTool
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET TestItem=ConfirmUEFI%1
SET Log=ConfirmUEFI%1.log
SET log_path=%tool_path%\%log%
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat

set /a EXITCODE=255

:ConfirmUEFI
rem del log file
del /f %log%
del /f MANUFACTURING.log
Tools\LANRS-Diags.exe /RD -ip %ip% -rf "%log_path%"

rem run remote confirm UEFI
Tools\LANRS-diags.exe /e -ip %ip% -w -ex -f "cmd.exe /c C:\tools\UnlockScript\GetUefiRuntimeMode.exe >%log_path%"
set /a exitcode1=%errorlevel%

rem get log file
Tools\LANRS-diags.exe /Q -ip %ip% -rf "%log_path%"
if %errorlevel% neq 0 set EXITCODE=255 & goto Faillog

echo C:\tools\UnlockScript\GetUefiRuntimeMode.exe errorcode=%exitcode1% >>%log%

rem check log file string
find /i "MANUFACTURING_MODE" %log%
set EXITCODE=%errorlevel%

if %EXITCODE%==0 goto Passlog
if %EXITCODE%==1 echo 1 > MANUFACTURING.log & goto Passlog

:Faillog
SET EXIT_PF=FAIL
GOTO backup

:Passlog
SET EXIT_PF=PASS

:backup
IF NOT EXIST %Log% GOTO END
Tools\LogTransfer-auto.exe -nl /de -
call setdate.bat
SET DEST=%TestItem%\%datepath%\%EXIT_PF%
IF NOT EXIST %MISC%\%DEST% MKDIR %MISC%\%DEST%
Copy %Log% %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%.log

:End
if "%1" equ "" set EXITCODE=0
EXIT /B %EXITCODE%



