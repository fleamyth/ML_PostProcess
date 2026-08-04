@echo on
cd %~dp0..
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat
SET TestItem=FREQ_2K
SET Log=Tools\Diagtool\record.wav
IF EXIST sn.dat SET /p SN=<sn.dat
IF EXIST TSRID.dat SET /p TSRID=<TSRID.dat


:Left
Tools\Diagtool\Audio-diags.exe /playrec Tools\Diagtool\2khz.wav






:backup
rem IF NOT EXIST %Log% GOTO END
Tools\LogTransfer-auto.exe -nl /de -
call setdate.bat
SET DEST=%TestItem%\%datepath%
IF NOT EXIST %MISC%\%DEST% MKDIR %MISC%\%DEST%
Copy %Log% %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%.wav
exit /b 0



