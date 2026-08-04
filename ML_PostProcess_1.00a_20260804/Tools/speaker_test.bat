@echo off

start API-diag.exe -nl -p "c:\jdm1\diagtool\speaker.bat" /iaac
btn-diag.exe /btns btn_spk.ini
API-diag.exe -nl -p "c:\jdm1\diagtool\RemoteKey-auto_Rev1.00a.exe" -arg "/spk %errorlevel%" /iaac
