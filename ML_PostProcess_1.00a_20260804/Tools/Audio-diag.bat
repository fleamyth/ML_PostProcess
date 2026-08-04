@echo off
cd %~dp0..
DEL SPK_*.log HS_*.log AudioLog.txt AudioLog_*.log *.wav" >nul
Tools\Audio-diag.exe -spk -mic -amp 0.2 -ampr 0.2 -timeout 5 -t 3 /lr 1000 2000
IF %ERRORLEVEL% NEQ 0 EXIT /b %ERRORLEVEL%
Call Tools\Audio_Analyze.bat S
IF %ERRORLEVEL% NEQ 0 EXIT /b %ERRORLEVEL%

:GetValue
Tools\PT-diags.exe -nl /gv AudioLog_SL.log "Left Frequency = " 900 1100
IF %ERRORLEVEL% NEQ 0 EXIT /B 3
Tools\PT-diags.exe -nl /gv AudioLog_SL.log "Right Frequency = " 900 1100
IF %ERRORLEVEL% NEQ 0 EXIT /B 3
Tools\PT-diags.exe -nl /gv AudioLog_SR.log "Left Frequency = " 1900 2100
IF %ERRORLEVEL% NEQ 0 EXIT /B 3
Tools\PT-diags.exe -nl /gv AudioLog_SR.log "Right Frequency = " 1900 2100
IF %ERRORLEVEL% NEQ 0 EXIT /B 3
ECHO PASS
