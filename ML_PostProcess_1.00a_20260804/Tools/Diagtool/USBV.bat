@echo off
cd %~dp0
del usvb.log
usbv-diags.exe -o -q /Save usbv.log
exit /b 0