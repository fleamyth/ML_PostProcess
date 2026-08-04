@echo on
cd %~dp0..
set /p IP=<IP.dat
set tool_path=c:\DiagTool
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET TestItem=Device
SET Log=Device_check.log
SET log_path=%tool_path%\%log%
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat

set /a exitcode=255

del %log%
Tools\LANRS-diags.exe /rd -ip %ip% -rf "%log_path%"

:Test
Tools\LANRS-diags.exe /s -ip %ip% -f "tools\device_check.ini" -rto "C:\diagtool"


Tools\LANRS-diags.exe /e -ip %ip% -w -ex -f "c:\diagtool\Devag-diags.exe -ab -dis -in /c %tool_path%\device_check.ini"
set /a exitcode=%errorlevel%
if %exitcode% equ 0 goto Passlog

:get device list
Tools\LANRS-diags.exe /e -ip %ip% -w -ex -f "c:\diagtool\Devag-diags.exe -auto -redu /cf %log_path%"

Tools\LANRS-diags.exe /Q -ip %ip% -rf "%log_path%"

findstr "!" %log% > device_fail.log
if %errorlevel% neq 0 set /a exitcode=0 & goto passlog

:device_pass
setlocal enabledelayedexpansion
FOR /F "tokens=1 delims=" %%i IN (device_fail.log) DO (
find /i "%%i" tools\device_pass.ini
if !errorlevel! neq 0 goto faillog
)

set /a exitcode=0
goto Passlog 

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