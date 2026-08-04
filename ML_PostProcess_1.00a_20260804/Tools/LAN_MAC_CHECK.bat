@echo off
cd %~dp0..
set /p IP=<IP.dat
set tool_path=c:\DiagTool
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET TestItem=LAN_MAC_CHECK
SET Log=LAN_MAC_CHECK.log
SET log_path=%tool_path%\%log%
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat

set /p LAN_MAC=<LAN_MAC.dat
set /a exitcode=255

del %log%
Tools\LANRS-Diags.exe /RD -ip %ip% -rf "%log_path%"


:EEUPDATE_READ_MAC
Tools\LANRS-diags.exe /e -ip %ip% -w -ex -f "cmd.exe /c C:\diagtool\LAN\EEupdate\EEUPDATEW64e /NIC=1 /MAC_DUMP >%log_path%"
if %errorlevel% neq 0 goto faillog

rem get log from DUT
Tools\LANRS-diags.exe /Q -ip %ip% -rf "%log_path%"
if %errorlevel% neq 0 goto faillog

:check_mac
find /c /i "88-88-88" %Log%
if %errorlevel% equ 0 goto Faillog

:check_mac_v
find /c /i "%LAN_MAC%" %Log%
if %errorlevel% equ 0 set /a exitcode=0 & goto Passlog

:Faillog
SET EXIT_PF=FAIL
GOTO backup

:Passlog
SET EXIT_PF=PASS

:backup
IF NOT EXIST %Log% GOTO END
echo --- Get LAN MAC address-- >>%Log%
echo %LAN_MAC% >>%Log%
Tools\LogTransfer-auto.exe -nl /de -
call setdate.bat
SET DEST=%TestItem%\%datepath%\%EXIT_PF%
IF NOT EXIST %MISC%\%DEST% MKDIR %MISC%\%DEST%
Copy %Log% %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%.log

:end
exit /b %exitcode%