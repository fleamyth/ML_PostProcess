@echo off
cd %~dp0..
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat

SET TestItem=Speaker
SET Log=AudioLog.txt
SET WAV=audio-diag.wav
REM %3=L/R
REM %4=L/R
REM Peak Range=%5 %6
REM %7=D/F
IF EXIST AudioLog.txt DEL AudioLog.txt
IF "%3" EQU "L" SET SPK=Left
IF "%3" EQU "R" SET SPK=Right
IF "%3" EQU "" SET EXITCODE=255& GOTO fail

IF "%4" EQU "L" SET Channel=Left
IF "%4" EQU "R" SET Channel=Right
IF "%4" EQU "" SET EXITCODE=255& GOTO fail

IF "%7" EQU "D" Set Check=dB&GOTO start
IF "%7" EQU "F" Set Check=Frequency&GOTO start
IF "%7" EQU "" SET EXITCODE=255

REM IF "%4" EQU "B" SET Mic_Ch=BMic
REM IF "%4" EQU "F" SET Mic_Ch=FMic
REM IF "%4" EQU "" SET EXITCODE=255& GOTO fail

REM IF "%3" EQU "R" IF "%4" EQU "F" del LF.flg
REM IF "%3" EQU "L" IF "%4" EQU "B" del RB.flg
REM IF "%3" EQU "L" IF "%4" EQU "F" IF EXIST LF.flg DEL LF.flg & EXIT /b 0
REM IF "%3" EQU "R" IF "%4" EQU "B" IF EXIST RB.flg DEL RB.flg & EXIT /b 0

IF EXIST SPK_%SPK%_%Channel%_%Check%.log DEL SPK_%SPK%_%Channel%_%Check%.log
:start
IF NOT EXIST audio-diag.wav echo audio-diag.wav is not exist > AudioLog.txt & SET EXITCODE=255&GOTO fail
REM Get analyze file AudioLog.txt
Tools\KrownAudio-Diags.exe -nl -ffts 0.5 -f audio-diag.wav -peak %5 /g
SET EXITCODE=%ERRORLEVEL%
ECHO.
IF %EXITCODE% EQU 0 GOTO analyze

SET EXIT_PF=FAIL
ECHO ============================
ECHO Get AudioLog.txt Fail
ECHO ============================
GOTO backup

:analyze
echo.
REM judge the analyze file
Tools\pt-diags.exe /gv AudioLog.txt "%Channel% %Check% = " %1 %2 > SPK_%SPK%_%Channel%_%Check%.log
SET EXITCODE=%ERRORLEVEL%
ECHO.
ECHO ============================
ECHO AnalyzeERRORCode = %EXITCODE%

set /p value=<SPK_%SPK%_%Channel%_%Check%.log
IF %EXITCODE% EQU 0 goto Passlog
IF %EXITCODE% EQU 1 echo %SPK% Speaker %Channel% %Check% (%value%) is lower than its limit %1.
IF %EXITCODE% EQU 2 echo %SPK% Speaker %Channel% %Check% (%value%) is greater than its limit %2.
IF ERRORLEVEL 3 ECHO. >SPK_%SPK%_%Channel%_%Check%.log

:Faillog
SET EXIT_PF=FAIL
ECHO ============================
GOTO backup

:Passlog
SET EXIT_PF=PASS
ECHO ============================

:backup
Tools\LogTransfer-auto.exe -nl /de
call setdate.bat
SET DEST=%datepath%\%TestItem%\%EXIT_PF%
IF NOT EXIST C:\MISClog\_Debug\%DEST% MKDIR C:\MISClog\_Debug\%DEST%
Copy %Log% C:\MISClog\_Debug\%DEST%\%SN%_%TSRID%_SPK_%SPK%_%Channel%_%Check%_%1_%2_%EXIT_PF%.log
Copy %WAV% C:\MISClog\_Debug\%DEST%\%SN%_%TSRID%_SPK_%SPK%_%Channel%_%Check%_%1_%2_%EXIT_PF%.wav
Tools\ping-auto.exe -nl /c 192.168.1.51
IF %ERRORLEVEL% NEQ 0 ECHO. & ECHO NO BACKUP TO DUT.. & GOTO End
Tools\File-diag.exe -nl /c2d %Log% c:\JDM1\log\FCT\%DEST%\%SN%_%TSRID%_SPK_%SPK%_%Channel%_%Check%_%1_%2_%EXIT_PF%.log
Tools\File-diag.exe -nl /c2d %WAV% c:\JDM1\log\FCT\%DEST%\%SN%_%TSRID%_SPK_%SPK%_%Channel%_%Check%_%1_%2_%EXIT_PF%.wav
:End
EXIT /B %EXITCODE%
