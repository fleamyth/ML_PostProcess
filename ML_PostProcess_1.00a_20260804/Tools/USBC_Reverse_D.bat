@echo off
cd %~dp0..
set /p IP=<IP.dat
set tool_path=c:\DiagTool
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET TestItem=USBC_Reverse_D
SET Log=%testitem%.log
SET log_path=%tool_path%\%log%
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat

set /a exitcode=255

del %log%
Tools\LANRS-diags.exe /rd -ip %ip% -w -f "%tool_path%\USBC_devcon.log"

set /a count=0

:get_first_status
del %2_value.log
if not exist %2.log goto faillog
tools\pt-diags.exe /gv %2.log ":" > %2_value.log
set /p USBC_stauts=<%2_value.log
set /a USBC1=USBC_stauts

:showtips
taskkill /im screen-diag.exe
chopper-diag.exe /delay 500
start tools\screen-diag.exe -nl /Spt tools\USBC_D_OFF.JPG

:plug_off_check
del USBC_devcon.log
if %count% equ %1 goto faillog
set /a count=%count%+1
chopper-diag.exe /delay 500

tools\lanrs-diags.exe /e -ip %ip% -w -ex -f "cmd.exe /c %tool_path%\devcon.exe /find *>%tool_path%\USBC_devcon.log"
if %errorlevel% neq 0 goto faillog

Tools\LANRS-diags.exe /Q -ip %ip% -rf "%tool_path%\USBC_devcon.log" 
if %errorlevel% neq 0 goto faillog

tools\pt-diags.exe /find "USBC_devcon.log" "Generic Pnp Monitor"
if %errorlevel% equ 0 goto plug_off_check

:switchtips
taskkill /im screen-diag.exe
chopper-diag.exe /delay 500
start tools\screen-diag.exe -nl /Spt tools\USBC_D_RIN.JPG

:plug_in_check
del USBC_devcon.log
if %count% equ %1 goto faillog
set /a count=%count%+1

tools\lanrs-diags.exe /e -ip %ip% -w -ex -f "cmd.exe /c %tool_path%\devcon.exe /find *>%tool_path%\USBC_devcon.log"
if %errorlevel% neq 0 goto faillog

Tools\LANRS-diags.exe /Q -ip %ip% -rf "%tool_path%\USBC_devcon.log" 
if %errorlevel% neq 0 goto faillog

tools\pt-diags.exe /find "USBC_devcon.log" "Generic Pnp Monitor"
if %errorlevel% equ 0 goto status

chopper-diag.exe /delay 500

goto plug_in_check

:status
tools\NIControl-diags.exe /gio 0.31 >%log%
if %errorlevel% neq 0 goto faillog

:reverse
tools\pt-diags.exe /gv %log% ":" > USBC_reverse_tmp.log
set /p USBC_reverse=<USBC_reverse_tmp.log
set /a USBC2=USBC_reverse

if %USBC1% equ %USBC2% goto showtips
goto passlog


:Faillog
SET EXIT_PF=FAIL
GOTO backup

:Passlog
set /a exitcode=0
SET EXIT_PF=PASS

:backup
IF NOT EXIST %Log% GOTO END
Tools\LogTransfer-auto.exe -nl /de -
call setdate.bat
SET DEST=%TestItem%\%datepath%\%EXIT_PF%
IF NOT EXIST %MISC%\%DEST% MKDIR %MISC%\%DEST%
Copy %Log% %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%.log

:End
taskkill /im screen-diag.exe
EXIT /B %EXITCODE%