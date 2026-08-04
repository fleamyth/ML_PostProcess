@echo off
cd %~dp0..
set /p IP=<IP.dat
set tool_path=c:\DiagTool
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET TestItem=USB_%1
SET Log=USB_%1.log
SET log_path=%tool_path%\%log%
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat

set /a exitcode=255

rem del local file
del %log%
del History.log
Tools\LANRS-diags.exe /rd -ip %ip% -w -f "%tool_path%\History.log"


:USB30
Tools\LANRS-diags.exe /s -ip %ip% -f ".\tools\Diagtool\%1.ini" -rto "%tool_path%"
if %errorlevel% neq 0 goto faillog

Tools\LANRS-diags.exe /e -ip %ip% -w -ex -f "%tool_path%\USB30-diags.exe /T %tool_path%\%1.ini"
set /a exitcode=%errorlevel%

rem get log file from DUT
Tools\LANRS-diags.exe /Q -ip %ip% -rf "c:\server\History.log"

rename History.log %log%

if %exitcode% equ 0 goto Passlog
 
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