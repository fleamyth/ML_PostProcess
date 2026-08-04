@echo off
cd %~dp0..
set /p IP=<IP.dat
set tool_path=c:\DiagTool
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET TestItem=%1
SET Log=%1.log
SET alllog=%1_all.log
SET log_path=%tool_path%\%log%
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat

set /a exitcode=255

set /a fan=%2
set /a lowlimit=%3
set /a highimit=%4
set /a timeout=30
set /a timeout=%5

del delta.log
del fanabs.log
del fan_tmp.log
del %log%
del %alllog%
set /a count=0
set /a fanSpeedsMax=0
set /a fanSpeedsMin=9999
set /a fanSpeeds=0
Tools\LANRS-diags.exe /rd -ip %ip% -rf "%log_path%"

:check
if %count% equ %timeout% goto Faillog
set /a count=%count%+1
rem chopper-diag.exe -nl /delay 750 >nul

:get_fan_speed
Tools\LANRS-diags.exe /e -ip %ip% -w -ex -f "cmd.exe /c c:\diagtool\Smonitor\SmonitorUAP.exe /readfanspeed %fan% >%tool_path%\fan_tmp.log"

rem get log file from DUT
Tools\LANRS-diags.exe /Q -ip %ip% -rf "%tool_path%\fan_tmp.log"

rem check log
tools\pt-diags /find fan_tmp.log "Pass"
if %errorlevel% neq 0 goto faillog

rem get hex value
tools\pt-diags /Gstr fan_tmp.log -sa 19 -ea 23 >fan_hex.log

rem hex to dec
tools\pt-diags /h2d fan_hex.log >fan_dec.log

rem check value
tools\pt-diags /GV fan_dec.log "" %3 %4 > fan_speed.log
set /a exitcode=%errorlevel%

set /p fanSpeeds=<fan_speed.log

if %fanSpeeds% gtr %fanSpeedsMax% set /a fanSpeedsMax=%fanSpeeds%
if %fanSpeeds% lss %fanSpeedsMin% set /a fanSpeedsMin=%fanSpeeds%

echo Test Item: %TestItem%>>%alllog%
echo Time:%count% second>>%alllog%
echo Fan speeds=%fanSpeeds%>>%alllog%
echo Max Fan speeds=%fanSpeedsMax%>>%alllog%
echo Min Fan speeds=%fanSpeedsMin%>>%alllog%
echo low limit=%lowlimit%>>%alllog%
echo high limit=%highimit%>>%alllog%
echo "return code: %exitcode%">>%alllog%
echo --- >>%alllog%
cls
echo Test Item: %TestItem%
echo times: %count%
echo FAN speed: %fanSpeeds%
echo low limit: %lowlimit%
echo high limit: %highimit%
echo MAX Fan Speed: %fanSpeedsMax%
echo %fanSpeeds% > %log%
if %exitcode% equ 0 goto passlog
GOTO CHECK

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
Copy %allLog% %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%.log


:End
EXIT /B %exitcode%