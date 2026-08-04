@echo off
cd %~dp0..

Tools\ping-auto.exe /P 192.168.1.10 -t 3
set /a exitcode=%errorlevel%

:End
EXIT /B 255