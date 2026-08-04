@echo on
cd %~dp0
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET TestItem=USB_%1_%2
SET Log=USB_%1_%2.log
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat





:USB30
USB31-diags.exe /T %3
if %errorlevel% equ 0 goto Passlog

 
:Faillog
SET EXIT_PF=FAIL
set /a EXITCODE=255
GOTO backup

:Passlog
SET EXIT_PF=PASS
set /a EXITCODE=0

:backup
rem IF NOT EXIST %Log% GOTO END
LogTransfer-auto.exe -nl /de -
call setdate.bat
SET DEST=%TestItem%\%datepath%\%EXIT_PF%
IF NOT EXIST %MISC%\%DEST% MKDIR %MISC%\%DEST%
Copy history.log %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%.log


:End
EXIT /B %EXITCODE%