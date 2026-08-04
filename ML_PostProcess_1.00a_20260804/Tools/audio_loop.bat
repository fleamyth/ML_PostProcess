@echo off
cd %~dp0..
set /a error=255
if exist hp.log del hp.log
tools\File-diag.exe /fe c:\jdm1\diagtool\audio-diag.wav
if %errorlevel% equ 0 File-diag.exe /df c:\jdm1\diagtool\audio-diag.wav

tools\API-diag.exe -nl -p C:\JDM1\DiagTool\Audio-diag.exe -arg "-f c:\jdm1\diagtool\audio-diag.wav /playrec C:\JDM1\DiagTool\1000_2000_05.wav -time 3" /iac
timeout /t 1 /nobreak
rem tools\API-diag.exe -nl -r hp_loop.log -p C:\JDM1\DiagTool\Audio-diag.exe -arg "-f c:\jdm1\diagtool\record.wav /fft 900 1100" /iac
rem echo %errorlevel%
tools\File-diag.exe /cfd c:\jdm1\diagtool\audio-diag.wav %~dp0..\audio-diag.wav
if %errorlevel% equ 0 set /a error=0
exit /b %error%
