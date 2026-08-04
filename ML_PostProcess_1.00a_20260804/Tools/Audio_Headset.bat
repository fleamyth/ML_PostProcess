@echo off
cd %~dp0..
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat

SET TestItem=Headset
SET Log=AudioLog.txt
SET WAV=audio-diag.wav

REM %3=L/R
REM %4=D/F/T/S
REM Peak Range=%5 %6
IF EXIST AudioLog.txt DEL AudioLog.txt
IF "%3" EQU "L" SET Mic_Ch=Left
IF "%3" EQU "R" SET Mic_Ch=Right
IF "%3" EQU "" SET EXITCODE=255& GOTO fail
REM Left channel peak 1000, Right channel peak 2000 

IF "%4" EQU "D" Set Check=dB&GOTO start
IF "%4" EQU "F" Set Check=Frequency&GOTO start
IF "%4" EQU "T" Set Check=THD&GOTO start
IF "%4" EQU "S" Set Check=SNR&GOTO SNRCHK
IF "%4" EQU "" SET EXITCODE=255
echo Parameter Error! %1 %2 %3 %4 %5 %6>AudioLog.txt
GOTO fail
IF EXIST HS_%Mic_Ch%_%Check%.log DEL HS_%Mic_Ch%_%Check%.log
:start
IF NOT EXIST audio-diag.wav echo audio-diag.wav is not exist >AudioLog.txt& SET EXITCODE=255&GOTO fail
REM %5 %6 set peak range 
IF "%Mic_Ch%" EQU "Left" GOTO Left
IF "%Mic_Ch%" NEQ "Left" GOTO Right

:Left
Tools\KrownAudio-Diags.exe -nl -f audio-diag.wav -thdsi 3 -fr %5 %6 /g
SET EXITCODE=%ERRORLEVEL%
ECHO.
IF %EXITCODE% EQU 0 GOTO analyze

SET EXIT_PF=FAIL
ECHO ============================
ECHO Get AudioLog.txt Fail
ECHO ============================
GOTO backup

:Right
Tools\KrownAudio-Diags.exe -nl -f audio-diag.wav -fr %5 %6 /g
SET EXITCODE=%ERRORLEVEL%
ECHO.
IF %EXITCODE% EQU 0 GOTO analyze

SET EXIT_PF=FAIL
ECHO ============================
ECHO Get AudioLog.txt Fail
ECHO ============================
GOTO backup

:SNRCHK
REM copy
IF NOT EXIST Tools\SNR.wav echo Tools\SNR.wav is not exist  > AudioLog.txt & SET EXITCODE=255&GOTO fail
Tools\KrownAudio-Diags.exe -nl -f Tools\SNR.wav -stdf audio-diag.wav -vrms 100 /c
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
Tools\pt-diags.exe /gv AudioLog.txt "%Mic_Ch% %Check% = " %1 %2 >HS_%Mic_Ch%_%Check%.log
SET EXITCODE=%ERRORLEVEL%
ECHO.
ECHO ============================
ECHO AnalyzeERRORCode = %EXITCODE%

set /p value=<HS_%Mic_Ch%_%Check%.log
IF %EXITCODE% EQU 0 goto Passlog
IF %EXITCODE% EQU 1 echo %Mic_Ch% %Check% (%value%) is lower than its limit %1.
IF %EXITCODE% EQU 2 echo %Mic_Ch% %Check% (%value%) is greater than its limit %2.
IF ERRORLEVEL 3 ECHO. >HS_%Mic_Ch%_%Check%.log

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
if %EXIT_PF%==PASS goto backup1
IF NOT EXIST C:\MISClog\_Debug\%DEST% MKDIR C:\MISClog\_Debug\%DEST%
Copy %Log% C:\MISClog\_Debug\%DEST%\%SN%_%TSRID%_HS_%Mic_Ch%_%Check%_%1_%2_%EXIT_PF%.log
Copy %WAV% C:\MISClog\_Debug\%DEST%\%SN%_%TSRID%_HS_%Mic_Ch%_%Check%_%1_%2_%EXIT_PF%.wav
:backup1
Tools\ping-auto.exe -nl /c 192.168.1.51
IF %ERRORLEVEL% NEQ 0 ECHO. & ECHO NO BACKUP TO DUT.. & GOTO End
Tools\File-diag.exe -nl /c2d %Log% c:\JDM1\log\FCT\%DEST%\%SN%_%TSRID%_HS_%Mic_Ch%_%Check%_%1_%2_%EXIT_PF%.log
Tools\File-diag.exe -nl /c2d %WAV% c:\JDM1\log\FCT\%DEST%\%SN%_%TSRID%_HS_%Mic_Ch%_%Check%_%1_%2_%EXIT_PF%.wav
:End
EXIT /B %EXITCODE%












:pass
SET EXITCODE=0
ECHO PASS

:fail
Tools\LogTransfer-auto.exe -nl /de -
call setdate.bat
set result=FAIL
IF %EXITCODE% EQU 0 set result=PASS
set savepath=%~dp0..\log\Audiolog\%datepath%\%result%
IF NOT EXIST %savepath% mkdir %savepath%
set /p SN=<sn.dat
set /p TSRID=<TSRID.dat
copy audio-diag.wav %savepath%\%SN%_%TSRID%_%Mic_Ch%_%Check%_%1_%2.wav
copy AudioLog.txt %savepath%\%SN%_%TSRID%_%Mic_Ch%_%Check%_%1_%2.log

IF %EXITCODE% EQU 0 goto end
REM ping 192.168.1.51 -n 1 | findstr /R /C:"^¦^ÂÐ¦Û.*TTL="
REM ping 192.168.1.51 -n 1 | findstr /R /C:"^Reply from.*TTL="
Tools\ping-auto.exe -nl /c
IF %ERRORLEVEL% NEQ 0 goto end
Tools\File-diag.exe -nl /DE C:\Audiolog\
IF %ERRORLEVEL% NEQ 0 File-diag.exe /CD C:\Audiolog\
Tools\File-diag.exe -nl /C2D audio-diag.wav C:\Audiolog\%SN%_%TSRID%_%Mic_Ch%_%Check%_%1_%2.log
Tools\File-diag.exe -nl /C2D AudioLog.txt C:\Audiolog\%SN%_%TSRID%_%Mic_Ch%_%Check%_%1_%2.wav
:end
del setdate.bat
exit /b %EXITCODE%
