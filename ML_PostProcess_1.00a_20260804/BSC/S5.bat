@ECHO OFF
cd %~dp0..

ECHO 12VB_S5_current_CTL  (current control = 1)
Tools\NIControl-diags.exe -nl /sio 0.12 1
Chopper-diag.exe /delay 1000 2>nul

ECHO PSU 12VB_CTL 
Tools\NIControl-diags.exe -nl /sio 0.10 0

ECHO PSU 12VA_CTL 
Tools\NIControl-diags.exe -nl /sio 0.9 0

exit /b 0
