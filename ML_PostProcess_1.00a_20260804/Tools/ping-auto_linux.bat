@echo off
cd %~dp0..
:set_misc
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET PINGTIME=%2
IF "%2" EQU "" SET PINGTIME=120
SET TestItem=Boot_Linux
SET Log=Diags_Compare.bmp
IF EXIST SN.dat SET /p SN=<SN.dat
IF EXIST TSRID.dat SET /p TSRID=<TSRID.dat

:ping_linux
Tools\ping-auto.exe /P 192.168.1.10 -t %PINGTIME%
SET EXITCODE=%ERRORLEVEL%
ECHO ERRORCode = %EXITCODE%
IF %EXITCODE% EQU 0 del boot_linux.log & goto END

SET EXIT_PF=FAIL

:linux reboot
rem restart DHCP
call Tools\DHCP.bat

rem poweroff
call tools\POWER_OFF_NI.bat
if exist boot_linux.log del boot_linux.log & goto backup

rem wait poweroff
chopper-diag.exe /delay 10000

rem power on to Linux
call tools\POWER_ON_LINUX.bat

echo 1 > boot_linux.log

:backup
IF NOT EXIST %Log% GOTO END
Tools\LogTransfer-auto.exe -nl /de -
call setdate.bat
SET DEST=%TestItem%\%datepath%\%EXIT_PF%
IF NOT EXIST %MISC%\%DEST% MKDIR %MISC%\%DEST%
Copy %Log% %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%_%boot_time%.bmp

:End
IF %EXITCODE% NEQ 0 echo modsretest>modsretest.dat
EXIT /b 0