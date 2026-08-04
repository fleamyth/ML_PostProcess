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
rem DEL .\Tools\Diagtool\*.wav
rem DEL .\Tools\Diagtool\*.ini
DEL .\Tools\Diagtool\*.txt
DEL .\Tools\Diagtool\*.tmp
DEL .\Tools\Diagtool\*.flg
rd /q /s LANRSClientlogs
rd /q /s LANRSserverlogs

set /a exitcode=255
set /a count=0

del %Log%

Tools\LANRS-diags.exe /RCF -ip %ip% -w -RF "%tool_path%\Diags.key"
ECHO check access file success before filecopy:%errorlevel% >%Log%

Tools\LANRS-diags.exe /e -ip %ip% -w -ex -f "cmd.exe /c del %tool_path%\*.dat"
Tools\LANRS-diags.exe /e -ip %ip% -w -ex -f "cmd.exe /c del %tool_path%\*.log"
Tools\LANRS-diags.exe /e -ip %ip% -w -ex -f "cmd.exe /c del %tool_path%\*.wav"
Tools\LANRS-diags.exe /e -ip %ip% -w -ex -f "cmd.exe /c del %tool_path%\*.ini"
Tools\LANRS-diags.exe /e -ip %ip% -w -ex -f "cmd.exe /c del %tool_path%\*.txt"
Tools\LANRS-diags.exe /e -ip %ip% -w -ex -f "cmd.exe /c del %tool_path%\*.tmp"
Tools\LANRS-diags.exe /e -ip %ip% -w -ex -f "cmd.exe /c rd /q /s %tool_path%\LANRSserverlogs"
Tools\LANRS-diags.exe /e -ip %ip% -w -ex -f "cmd.exe /c rd /q /s %tool_path%\LANRSClientlogs"

:diagkey
copy .\tools\DiagKey\Diags.key .\tools\Diagtool\Diags.key
rem copy .\tools\DiagKey\Diags.cfg .\tools\Diagtool\Diags.cfg
tools\LANRS-Diags.exe /S -ip %ip% -f ".\tools\DiagKey\Diags.key" -rto "C:" 
rem tools\LANRS-Diags.exe /S -ip %ip% -f ".\tools\DiagKey\Diags.cfg" -rto "C:" 

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
tools\pt-diags.exe /gstr md5_ipc.log -sl 1 -el 1 >md5_ipc_value.log
set /p md5_ipc=<md5_ipc_value.log

tools\pt-diags.exe /gstr md5_dut.log -sl 1 -el 1 >md5_dut_value.log
set /p md5_dut=<md5_dut_value.log

if "%md5_dut%" equ "%md5_ipc%" set /a exitcode=0 & goto passlog

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

Tools\LANRS-diags.exe /RCF -ip %ip% -w -RF "%tool_path%\Diags.key"
ECHO check access file success after filecopy:%errorlevel% >>%Log%

IF NOT EXIST %Log% GOTO END
Tools\LogTransfer-auto.exe -nl /de -
call setdate.bat
SET DEST=%TestItem%\%datepath%\%EXIT_PF%
IF NOT EXIST %MISC%\%DEST% MKDIR %MISC%\%DEST%
Copy %Log% %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%.log

:End
EXIT /B %EXITCODE%