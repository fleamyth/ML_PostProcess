@echo off
cd %~dp0..
set /p IP=<IP.dat
set tool_path=c:\DiagTool
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET TestItem=%1_Enumeration
SET Log=%1_Enumeration.log
SET log_path=%tool_path%\%log%
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat

set /a exitcode=255

rem del local file
del %log%
Tools\LANRS-diags.exe /rd -ip %ip% -w -f "%tool_path%\usbv.log"

:get
Tools\LANRS-diags.exe /E -ip %ip% -w -ex -f "cmd.exe /c %tool_path%\usbv.bat"
if %ERRORLEVEL% neq 0 goto Faillog

Tools\LANRS-diags.exe /Q -ip %ip% -rf "%tool_path%\usbv.log"
if %ERRORLEVEL% neq 0 goto Faillog

tools\pt-diags.exe /find usbv.log "%2" >%log%
if %ERRORLEVEL% neq 0 goto Faillog

tools\pt-diags.exe /find %log% "%3"
if %ERRORLEVEL% neq 0 goto Faillog

set /a exitcode=0
GOTO Passlog


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
if %EXITCODE% neq 0 Copy USBV.log %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%_USBV.log

:End
EXIT /B %EXITCODE%