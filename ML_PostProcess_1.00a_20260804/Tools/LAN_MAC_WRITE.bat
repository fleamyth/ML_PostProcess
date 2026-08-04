:@echo off
cd %~dp0..
set /p IP=<IP.dat
set tool_path=c:\DiagTool
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET TestItem=LAN_MAC_WRITE
SET Log=LAN_MAC_WRITE.log
SET log_path=%tool_path%\%log%
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat

set /a exitcode=255

if not exist LAN_MAC.dat goto end

del %log%
echo write MAC address is: >%log%
type LAN_MAC.dat >>%log%
echo __Get Lan Mac Address >>%log%
echo ****************************************************** >>%log%
echo Step >>%log%
echo ****************************************************** >>%log%

:del_log
Tools\LANRS-Diags.exe /RD -ip %ip% -rf "%tool_path%\EEUPDATEW64e.log"

:copy
echo del LAN MAC address file to DUT >>%log%
Tools\LANRS-Diags.exe /RD -ip %ip% -rf "%tool_path%\LAN_MAC.dat"
if %errorlevel% neq 0 goto faillog

echo copy LAN MAC address file to DUT >>%log%
Tools\LANRS-diags.exe /s -ip %ip% -f "LAN_MAC.dat" -rto "%tool_path%"
if %errorlevel% neq 0 goto faillog

:write
echo run write LAN MAC address to DUT and restart the LAN device >>%log%
Tools\LANRS-diags.exe /e -ip %ip% -timeout 30 -f "C:\DIAGTOOL\LAN_DUT_MAC.bat"
rem if %errorlevel% neq 0 goto faillog

rem Chopper-diag.exe /delay 8000

:Reboot
call Tools\poweroff_check.bat 60
if %errorlevel% neq 0 set /a exitcode=1 & goto Faillog
echo Complete poweroff check >>%log%

Tools\ping-auto.exe /P 192.168.1.10 -t 300
if %errorlevel% neq 0 set /a exitcode=2 & goto Faillog
echo Complete Reboot_Boot Status Check >>%log%


set /a count_server=0
:Check_Server
if %count_server% equ 6 set /a exitcode=3 & goto Faillog
Chopper-diag.exe /delay 15000
Tools\LANRS-diags.exe /Q -ip 192.168.1.10 -rf "c:\server\server.bat"
set /a exitcode=%errorlevel%
if %exitcode% equ 0 goto Complete_Check_Server
set /a count_server=%count_server%+1
goto Check_Server
:Complete_Check_Server
echo Complete Reboot_LANRS Server Check >>%log%
set /a exitcode=255

:log
rem check log file in DUT
Tools\LANRS-diags.exe /rcf -ip %ip% -rf "%tool_path%\EEUPDATEW64e.log"
if %errorlevel% neq 0 goto faillog
echo Complete DUT log file >>%log%

rem get log file
Tools\LANRS-diags.exe /Q -ip %ip% -rf "%tool_path%\EEUPDATEW64e.log"
if %errorlevel% neq 0 goto faillog
echo Complete Get DUT log file >>%log%

echo ****************************************************** >>%log%
echo EEUPDATEW64e LOG >>%log%
echo ****************************************************** >>%log%

type EEUPDATEW64e.log >>%log%

Tools\ping-auto.exe /P %ip% -t 30
if %errorlevel% neq 0 goto faillog

set /a exitcode=0
goto Passlog
rem if %error% equ 0 goto Passlog

:Faillog
SET EXIT_PF=FAIL
GOTO backup

:Passlog
SET EXIT_PF=PASS

:backup
IF NOT EXIST %Log% GOTO END
Tools\LogTransfer-auto.exe -nl /de -
call setdate.bat
SET DEST=%TestItem%\%datepath%\%EXIT_PF%
IF NOT EXIST %MISC%\%DEST% MKDIR %MISC%\%DEST%
Copy %Log% %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%.log

:end
exit /b %exitcode%