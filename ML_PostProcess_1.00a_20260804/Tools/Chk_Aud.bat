@echo on
cd %~dp0

set tool_path=C:\diagTool
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat
SET Log=CHKAUD_DEV.log
SET log_path=%tool_path%\%log%
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat
set /a EXITCODE=255
SET TestItem=Check_Aud_Dev
if exist CHKAUD_DEV.log del CHKAUD_DEV.log


Diagtool\Audio-diag.exe /LD > %Log%
Diagtool\Audio-diag.exe /chkact "%1"

if %errorlevel% equ 0 set /a EXITCODE=0 & goto Passlog

:Faillog
SET EXIT_PF=FAIL
GOTO backup

:Passlog
SET EXIT_PF=PASS
set /a EXITCODE=0

:backup
IF NOT EXIST %Log% GOTO END
LogTransfer-auto.exe -nl /de -
call setdate.bat
SET DEST=%TestItem%\%datepath%\%EXIT_PF%
IF NOT EXIST %MISC%\%DEST% MKDIR %MISC%\%DEST%
Copy %Log% %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%.log

:End
EXIT /B %EXITCODE%