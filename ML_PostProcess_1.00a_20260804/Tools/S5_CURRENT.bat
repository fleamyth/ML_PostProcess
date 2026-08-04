@echo off
REM RESULT=(VOLTAGE2-VOLTAGE1)*4/2*1000
REM Percent_L/R VOLTAGE1_IO VOLTAGE2_IO
cd %~dp0..
set /a error=255
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET TestItem=S5CURRENT
SET Log=S5current.log
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat
SET Logn=S5current
SET Vol1=%2
SET Vol2=%3
SET MIN=%4
SET MAX=%5


IF EXIST %Logn%*.log del %Logn%*.log
Tools\NIControl-diags.exe -nl /gv %Vol1% -1000 1000 > %Logn%_vol1.log
IF %ERRORLEVEL% EQU 255 EXIT /B 255

Tools\NIControl-diags.exe -nl /gv %Vol2% -1000 1000 > %Logn%_vol2.log
IF %ERRORLEVEL% EQU 255 EXIT /B 255

Tools\PT-diags.exe -nl /gv %1_vol1.log "Voltage: " -1000 1000 > %Logn%_vol1_num.log

Tools\PT-diags.exe -nl /gv %1_vol2.log "Voltage: " -1000 1000 > %Logn%_vol2_num.log

set /p V1=<%Logn%_vol1_num.log
set /p V2=<%Logn%_vol2_num.log

Tools\PT-diags.exe -nl -minus %V2% -mul 4 -div 10 -mul 1000 /gv %Logn%_vol1_num.log "" %min% %max% >%Logn%.log
set error=%errorlevel%
if %error% equ 0 goto passlog

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
Tools\ping-auto.exe -nl /c 192.168.1.10
IF %ERRORLEVEL% NEQ 0 GOTO End
Tools\File-diag.exe -nl /c2d %Log% c:\JDM1\log\FCT\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%.log

:End
EXIT /B %error%