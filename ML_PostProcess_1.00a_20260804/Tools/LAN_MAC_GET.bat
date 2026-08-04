:@echo off
cd %~dp0..
set /p IP=<IP.dat
set tool_path=c:\DiagTool
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET TestItem=LAN_MAC_GET
SET Log=LAN_MAC_GET.log
SET log_path=%tool_path%\%log%
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat

set /a exitcode=255

rem del local file
if exist LAN_MAC.dat del LAN_MAC.dat
if exist LAN_MAC.log del LAN_MAC.log

Tools\LANRS-Diags.exe /RD -ip %ip% -rf "%tool_path%\LAN_MAC.dat"
Tools\LANRS-Diags.exe /RD -ip %ip% -rf "%tool_path%\LAN_install.log"


:install
rem copy non pause LAN install.bat to Dut
Tools\LANRS-diags.exe /s -ip %ip% -f "tools\LAN_install.bat" -rto "c:\diagtool\lan\eeupdate"
if %errorlevel% neq 0 goto end

rem run LAN install.bat on DUT
Tools\LANRS-diags.exe /e -ip %ip% -w -ex -f "cmd.exe /c C:\diagtool\LAN\EEupdate\LAN_install.bat >%tool_path%\LAN_install.log"
if %errorlevel% neq 0 goto end

rem get LAN_install.log from DUT
Tools\LANRS-diags.exe /Q -ip %ip% -rf "%tool_path%\LAN_install.log"

:get_random
set R1=50
set R2=1A
set R3=C6
set /a R4=%random% %%90 +10
set /a R5=%random% %%90 +10
set /a R6=%random% %%90 +10
set MAC=%R1%%R2%%R3%%R4%%R5%%R6%
echo %MAC%>LAN_MAC.dat
set /a exitcode=0

:copymac
copy LAN_MAC.dat %log%
echo --->>%log%
echo LAN_install.log:>>%log%
type LAN_install.log >>%log%

:backup
IF NOT EXIST %Log% GOTO END
Tools\LogTransfer-auto.exe -nl /de -
call setdate.bat
SET DEST=%TestItem%\%datepath%\%EXIT_PF%
IF NOT EXIST %MISC%\%DEST% MKDIR %MISC%\%DEST%
Copy %Log% %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%.log

:end
exit /b %exitcode%
