@echo off
cd %~dp0..
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET PINGTIME=%2
IF "%2" EQU "" SET PINGTIME=120
SET TestItem=Boot
SET Log=%1_boot.log
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat

Tools\ping-auto.exe /P 192.168.1.51 -t %PINGTIME%
if %errorlevel% equ 0 exit /b 0
exit /b 255