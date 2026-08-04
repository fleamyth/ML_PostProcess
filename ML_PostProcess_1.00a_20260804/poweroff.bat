@echo off

Tools\PwrStateCtrl-diag.exe /poweroff
call Tools\Jig_PowerOff.bat
Tools\NIControl-diags.exe -nl /sio 0.10 0
Tools\NIControl-diags.exe -nl /sio 0.9 0

exit /b 0