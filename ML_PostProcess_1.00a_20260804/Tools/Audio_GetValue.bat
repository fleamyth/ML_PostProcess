@echo off
cd %~dp0..
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

IF EXIST SN.dat SET /p SN=<SN.dat
IF EXIST TSRID.dat SET /p TSRID=<TSRID.dat

REM %1 H/S, %2 MIN, %3 MAX, %4=L/R, %5Check: D/F/T/S, %6Mic_Ch:L/R %7Clear
IF "%7" EQU "C" DEL AudioLog*
IF "%1" EQU "S" SET from=SPK
IF "%1" EQU "H" SET from=HS
IF "%1" EQU "S" SET TestItem=Speaker
IF "%1" EQU "H" SET TestItem=Headset
IF "%1" EQU "" EXIT /B 255
SET Log=AudioLog_%1%4.log
SET WAV=audio-diag.wav

IF "%4" EQU "L" SET Source=Left
IF "%4" EQU "R" SET Source=Right
IF "%4" EQU "" EXIT /B 255

IF "%5" EQU "D" Set Check=dB
IF "%5" EQU "F" Set Check=Frequency
IF "%5" EQU "T" Set Check=THD
IF "%5" EQU "S" Set Check=SNR
IF "%5" EQU "S" SET Log=AudioLog_%Check%.log
IF "%5" EQU "" EXIT /B 255


IF "%6" EQU "L" SET Mic_Ch=Left
IF "%6" EQU "R" SET Mic_Ch=Right
IF "%6" EQU "" SET Mic_Ch=%Source%

IF "%Check%" EQU "SNR" IF NOT EXIST %Log% GOTO SNRAnalyze
IF NOT EXIST %Log% GOTO Analyze
GOTO GetValue

:Analyze
Call Tools\Audio_Analyze.bat %1 %4
IF %ERRORLEVEL% EQU 0 GOTO GetValue
SET EXITCODE=255
ECHO ============================
ECHO Get %Log% Fail
ECHO ============================
GOTO Faillog

:SNRAnalyze
Call Tools\Audio_Analyze.bat %Check%
IF %ERRORLEVEL% EQU 0 GOTO GetValue
SET EXITCODE=255
ECHO ============================
ECHO Get %Log% Fail
ECHO ============================
GOTO Faillog

:GetValue
IF EXIST %from%_%Source%_%Mic_Ch%_%Check%.log DEL %from%_%Source%_%Mic_Ch%_%Check%.log
echo.
Tools\PT-diags.exe /gv %Log% "%Mic_Ch% %Check% = " %2 %3 > %from%_%Source%_%Mic_Ch%_%Check%.log
SET EXITCODE=%ERRORLEVEL%
ECHO.
ECHO ============================
ECHO AnalyzeERRORCode = %EXITCODE%

set /p value=<%from%_%Source%_%Mic_Ch%_%Check%.log
IF %EXITCODE% EQU 0 goto Passlog
IF %EXITCODE% EQU 1 echo %Source% %TestItem% %Mic_Ch% %Check% (%value%) is lower than its limit %1.
IF %EXITCODE% EQU 2 echo %Source% %TestItem% %Mic_Ch% %Check% (%value%) is greater than its limit %2.
IF ERRORLEVEL 3 ECHO. >%from%_%Source%_%Mic_Ch%_%Check%.log

:Faillog
SET EXIT_PF=FAIL
ECHO ============================
GOTO backup

:Passlog
echo %Source% %TestItem% %Mic_Ch% %Check% (%value%) PASS.
SET EXIT_PF=PASS
ECHO ============================

:backup
Tools\LogTransfer-auto.exe -nl /de -
call setdate.bat
SET DEST=%TestItem%\%datepath%\%EXIT_PF%
IF NOT EXIST %MISC%\%DEST% MKDIR %MISC%\%DEST%
Copy %Log% %MISC%\%DEST%\%SN%_%TSRID%_%from%_%Source%_%Mic_Ch%_%Check%_%2_%3_%EXIT_PF%.log
Copy %WAV% %MISC%\%DEST%\%SN%_%TSRID%_%from%_%Source%_%Mic_Ch%_%Check%_%2_%3_%EXIT_PF%.wav
Tools\ping-auto.exe -nl /c 192.168.1.10
IF %ERRORLEVEL% NEQ 0 ECHO. & ECHO NO BACKUP TO DUT.. & GOTO End
Tools\File-diag.exe -nl /c2d %Log% c:\JDM1\log\FCT\%DEST%\%SN%_%TSRID%_%from%_%Source%_%Mic_Ch%_%Check%_%2_%3_%EXIT_PF%.log
Tools\File-diag.exe -nl /c2d %WAV% c:\JDM1\log\FCT\%DEST%\%SN%_%TSRID%_%from%_%Source%_%Mic_Ch%_%Check%_%2_%3_%EXIT_PF%.wav
:End
EXIT /B %EXITCODE%
