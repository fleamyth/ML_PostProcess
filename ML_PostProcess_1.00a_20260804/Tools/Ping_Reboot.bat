@echo off
cd %~dp0..

Tools\ping-auto.exe /P 192.168.1.10 -t 300
set /a exitcode=%errorlevel%

:End
IF %EXITCODE% NEQ 0 echo GetVolt>GetVolt.dat
EXIT /B %EXITCODE%