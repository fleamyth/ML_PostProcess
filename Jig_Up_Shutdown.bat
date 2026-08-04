@ECHO ON
cd %~dp0
del Jig_Up_Shutdown.log
if exist FOLDER.ini SET /p FOLDER=<FOLDER.ini
if not exist FOLDER.ini SET FOLDER=Cairns_FCT_MB_1.01am_20200324
echo start jig_poweroff > Jig_Up_Shutdown.log
call %~dp0%FOLDER%\Tools\Jig_PowerOff.bat
if %errorlevel% equ 0 GOTO Jig_up
cd %~dp0
echo start Shutdown >> Jig_Up_Shutdown.log
%~dp0%FOLDER%\Tools\LANRS-diags.exe /e -ip 192.168.1.10 -w -ex -f "cmd.exe /c shutdown /s"
echo start Jig_PowerOff >> Jig_Up_Shutdown.log
call %~dp0%FOLDER%\Tools\Jig_PowerOff.bat

:Jig_up
cd %~dp0
echo Complete Jig_PowerOff >> Jig_Up_Shutdown.log
%~dp0%FOLDER%\Tools\NIControl-diags.exe -nl /sio 0.10 0
echo Complete NI 10 >> Jig_Up_Shutdown.log
%~dp0%FOLDER%\Tools\NIControl-diags.exe -nl /sio 0.9 0
echo Complete NI 9 >> Jig_Up_Shutdown.log
CALL %~dp0DiagPGM\Jig_UP_FCT_MB.bat
cd %~dp0
echo Complete Jig_UP_FCT_MB >> Jig_Up_Shutdown.log
EXIT /B 0