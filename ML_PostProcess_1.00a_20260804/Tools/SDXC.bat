@echo on
cd %~dp0..
set /p IP=<IP.dat
set tool_path=c:\DiagTool
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET TestItem=SDXC
SET Log=SDXC.log
SET log_path=%tool_path%\%log%
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat

set /a %exitcode%=255

:SDFW
rem del log
del /f %log%
Tools\LANRS-diags.exe /rd -ip %ip% -rf "%tool_path%\SDXC_HWIDS.log"

rem run scripts
Tools\LANRS-diags.exe /e -ip %ip% -w -ex -f "cmd.exe /c c:\diagtool\devcon.exe hwids USB\VID_045E* >%tool_path%\SDXC_HWIDS.log"

rem get log file from DUT
Tools\LANRS-diags.exe /Q -ip %ip% -rf "%tool_path%\SDXC_HWIDS.log"

Tools\PT-diags -nl /find SDXC_HWIDS.log "USB\VID_045E&PID_090C&REV_" >%log%

:SDFW1
SET /p SDXC=<SDXC1.dat
Tools\PT-diags -nl /find %log% %SDXC%
set /a exitcode=%errorlevel%
if %exitcode% equ 0 goto Passlog

:SDFW2
if not exist SDXC2.dat goto SDFW3
SET /p SDXC=<SDXC2.dat
Tools\PT-diags -nl /find %log% %SDXC%
set /a exitcode=%errorlevel%
if %exitcode% equ 0 goto Passlog

:SDFW3
if not exist SDXC2.dat goto SDFW4
SET /p SDXC=<SDXC3.dat
Tools\PT-diags -nl /find %log% %SDXC%
set /a exitcode=%errorlevel%
if %exitcode% equ 0 goto Passlog

:SDFW4
if not exist SDXC2.dat goto SDFWLOG
SET /p SDXC=<SDXC4.dat
Tools\PT-diags -nl /find %log% %SDXC%
set /a exitcode=%errorlevel%
if %exitcode% equ 0 goto Passlog

:Faillog
SET EXIT_PF=FAIL
GOTO backup

:Passlog
SET EXIT_PF=PASS

:backup
IF NOT EXIST %Log% GOTO END
copy %log% tools\%log%
Tools\LogTransfer-auto.exe -nl /de -
call setdate.bat
SET DEST=%TestItem%\%datepath%\%EXIT_PF%
IF NOT EXIST %MISC%\%DEST% MKDIR %MISC%\%DEST%
Copy %Log% %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%.log

:End
EXIT /B %exitcode%