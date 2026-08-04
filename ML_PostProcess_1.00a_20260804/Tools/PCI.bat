@echo off
cd %~dp0..
set /p IP=<IP.dat
set tool_path=c:\DiagTool
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET TestItem=PCI
SET Log=PCI.log
SET log_path=%tool_path%\%log%
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat

DEL %log%
Tools\LANRS-diags.exe /rd -ip %ip% -w -f "%tool_path%\pci.ini"

:run
SET /a EXITCODE=0
rem send PCI.ini to DUT
Tools\LANRS-diags.exe /s -ip %ip% -f "tools\PCI.ini" -rto "C:\diagtool"

rem run PCI-diags.exe -f pci.ini /chkpci on DUT
Tools\LANRS-diags.exe /e -ip %ip% -w -ex -f "cmd.exe /c C:\diagtool\PCI-diags.exe -f %tool_path%\pci.ini /chkpci >%log_path%"
set /a EXITCODE=%errorlevel%

rem get log from DUT
Tools\LANRS-diags.exe /Q -ip %ip% -rf "%log_path%"
if %errorlevel% neq 0 goto faillog


:next
if %EXITCODE% neq 0 goto Faillog
SET /a EXITCODE=0 & GOTO Passlog

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

:End
EXIT /B %EXITCODE%