@echo off
rem cd %~dp0
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat
SET TestItem=OTP_Programming
SET Log=temp.log
IF EXIST sn.dat SET /p SN=<sn.dat
IF EXIST TSRID.dat SET /p TSRID=<TSRID.dat
rem del log_*.txt
del C:\Tool_FW\tool\tool\Drivers\Audio\2.65.30\Logs\Log*.txt
C:\Tool_FW\tool\tool\Drivers\Audio\2.65.30\OTP.cmd

rem if %errorlevel% neq 0 goto fail
rem echo %errorlevel%
rem echo pass
rem pause
rem exit /b 0
rem 
rem :fail
rem echo fail
rem pause
rem exit /b 255