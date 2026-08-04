@echo off
cd %~dp0..
set /p IP=<IP.dat
set tool_path=c:\DiagTool
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET TestItem=FileCheck
SET Log=FileCheck.log
SET log_path=%tool_path%\%log%
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat

DEL .\Tools\Diagtool\*.dat
DEL .\Tools\Diagtool\*.log
DEL .\Tools\Diagtool\*.wav
DEL .\Tools\Diagtool\*.ini
DEL .\Tools\Diagtool\*.txt
DEL .\Tools\Diagtool\*.tmp

set /a exitcode=255
set /a count=0
tools\LANRS-diags.exe /rd -ip %ip% -rf "%tool_path%\*.log"
tools\LANRS-diags.exe /rd -ip %ip% -rf "%tool_path%\*.wav"
tools\LANRS-diags.exe /rd -ip %ip% -rf "%tool_path%\*.txt"
tools\LANRS-diags.exe /rd -ip %ip% -rf "%tool_path%\*.ini"
tools\LANRS-diags.exe /rd -ip %ip% -rf "%tool_path%\*.txt"
tools\LANRS-diags.exe /rd -ip %ip% -rf "%tool_path%\*.tmp"

:diagkey
copy .\tools\DiagKey\Diags.key .\tools\Diagtool\Diags.key
copy .\tools\DiagKey\Diags.cfg .\tools\Diagtool\Diags.cfg
tools\LANRS-Diags.exe /S -ip %ip% -f ".\tools\DiagKey\Diags.key" -rto "C:" 
tools\LANRS-Diags.exe /S -ip %ip% -f ".\tools\DiagKey\Diags.cfg" -rto "C:" 

:filecheck
set /a count=%count%+1
if %count% equ 3 goto faillog
rem PC md5 diagtool folder
tools\lanrs-diags.exe /DMD5 -f ".\tools\diagtool" -md5f "md5_ipc.log"

rem DUT md5 c:\diagtool\ folder
Tools\LANRS-diags.exe /e -ip %ip% -w -ex -f "c:\server\lanrs-diags.exe /DMD5 -f "%tool_path%" -md5f "c:\server\md5_dut.log"

rem get log from DUT
Tools\LANRS-diags.exe /Q -ip %ip% -rf "c:\server\md5_dut.log"
if %errorlevel% neq 0 goto filecheck

rem compare
tools\pt-diags.exe /c md5_ipc.log md5_dut.log
if %errorlevel% neq 0 goto filecopy

set /a exitcode=0 & goto passlog

:filecopy
tools\LANRS-Diags.exe /RD -ip %ip% -rf "%tool_path%"

tools\LANRS-Diags.exe /SD -ip %ip% -f ".\tools\diagtool" -rto "c:" 
if %errorlevel% neq 0 goto faillog

goto filecheck

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