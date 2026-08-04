@echo off
set /a error=255
tools\API-diag.exe -p taskkill -arg "/f /im audio-diag.exe" /iac

:random_set
set /a num=%random% %%9+1
echo %num%

:play_audio
start tools\API-diag.exe -p c:\jdm1\diagtool\audio-diag.exe -arg "-do Speakers /play c:\jdm1\diagtool\%num%.wav" /iaac -timeout 1
:check
tools\btn-diag.exe /btns tools\btn_spk.ini -time 15
set /a checknum=%errorlevel%
echo %checknum%

:check
if %checknum% equ %num% set /a error=0
tools\API-diag.exe -p taskkill -arg "/f /im audio-diag.exe" /iac

:end
echo %error%
exit /b %error%
