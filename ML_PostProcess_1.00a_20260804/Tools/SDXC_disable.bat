@echo on
cd %~dp0..
set /p IP=<IP.dat
set tool_path=c:\DiagTool
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET TestItem=SDXC_disable
SET Log=SDXC_disable.log
SET log_path=%tool_path%\%log%
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat

set /a %exitcode%=255

:SDFW
rem del log
del /f %log%
Tools\LANRS-diags.exe /rd -ip %ip% -rf "%log_path%"

rem run scripts
Tools\LANRS-diags.exe /e -ip %ip% -w -ex -f "cmd.exe /c c:\diagtool\devcon.exe find USB\VID_045E* >%log_path%"

rem get log file from DUT
Tools\LANRS-diags.exe /Q -ip %ip% -rf "%log_path%"

Tools\PT-diags -nl /find %log% "USB\VID_045E&PID_090C"
if %errorlevel% neq 0 set /a exitcode=0

echo %exitcode%

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