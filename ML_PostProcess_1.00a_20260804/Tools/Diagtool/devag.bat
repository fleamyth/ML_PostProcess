@echo off
devag-diags.exe -ab -dis -in /c Device_check.ini
echo %errorlevel%
pause