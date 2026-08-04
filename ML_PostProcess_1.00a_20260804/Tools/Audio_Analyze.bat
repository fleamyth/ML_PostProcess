cd %~dp0..
IF NOT EXIST Tools\Diagtool\record.wav EXIT /B 255
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat
SET TestItem=%1_%2
SET Log=%1Log_%2.log
IF EXIST sn.dat SET /p SN=<sn.dat
IF EXIST TSRID.dat SET /p TSRID=<TSRID.dat


if %1 EQU FREQ goto FREQ
if %1 EQU dB goto dB
if %1 EQU THD goto THD



:FREQ
rem IF EXIST AudioLog_S?.log DEL AudioLog_S?.log
Tools\Diagtool\KrownAudio-Diags.exe -nl -f Tools\Diagtool\record.wav -fr %3 %4 /g > %1Log_%2.log
Tools\PT-diags.exe /gv %1Log_%2.log "Left Frequency = " %3 %4
if %errorlevel% neq 0 goto FAIL
goto PASS

:dB
rem if "%1" EQU "L" IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
Tools\Diagtool\KrownAudio-Diags.exe -nl -f Tools\Diagtool\record.wav -db %3 %4 /g > %1Log_%2.log
Tools\PT-diags.exe /gv %1Log_%2.log "Left dB = " %3 %4
rem if "%1" EQU "R" EXIT /B %ERRORLEVEL%
if %errorlevel% neq 0 goto FAIL
goto PASS

:THD
rem if "%1" EQU "L" IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
Tools\Diagtool\KrownAudio-Diags.exe -nl -f Tools\Diagtool\record.wav -thdd %3 %4 /g > %1Log_%2.log
Tools\PT-diags.exe /gv %1Log_%2.log "Left THD = " %3 %4
rem if "%1" EQU "R" EXIT /B %ERRORLEVEL%
if %errorlevel% neq 0 goto FAIL

:PASS
set EXITCODE=%errorlevel%
set EXIT_PF=PASS
echo %EXITCODE%
goto backup

:FAIL
set EXITCODE=%errorlevel%
set EXIT_PF=FAIL
echo %EXITCODE%


:backup
rem IF NOT EXIST %Log% GOTO END
Tools\LogTransfer-auto.exe -nl /de -
call setdate.bat
SET DEST=%TestItem%\%datepath%\%EXIT_PF%\
IF NOT EXIST %MISC%\%DEST% MKDIR %MISC%\%DEST%
rem Copy %Log% %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%_%4_%3.log
Copy %Log% %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%.log
exit /b %EXITCODE%
