@echo off
cd %~dp0..
set /a EXITCODE=255
set /a V3P3VSBtime=0
del /q PWROFF.log
del /q S5_3P3VSB.log

SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat
SET TestItem=PWROFF
SET Log=PWROFF.log

IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat

SET /p TPM_model=<TPM_type.dat

set timecount=60
if /i "%TPM_model%" == "NATIONZ" set timecount=180

:CONTROL_SW_1
ECHO CONTROL_SW_1 to Low
Tools\NIControl-diags.exe -nl /sio 0.0 0

:3P3VSB
cls
set /a V3P3VSBtime=%V3P3VSBtime%+1
echo wait timeout %V3P3VSBtime%
echo wait timeout %V3P3VSBtime% >>%log%
echo ..
if %V3P3VSBtime% equ %timecount% goto Faillog
Chopper-diag.exe /delay 1000 2> nul
ECHO.
ECHO Check 3P3VSB off
Tools\NIControl-diags.exe -nl /gv 4 -0.1 0.1 > S5_3P3VSB.log
if %ERRORLEVEL% EQU 0 set /a EXITCODE=0
type S5_3P3VSB.log >>%log%
IF %EXITCODE% NEQ 0 GOTO 3P3VSB
goto Passlog

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