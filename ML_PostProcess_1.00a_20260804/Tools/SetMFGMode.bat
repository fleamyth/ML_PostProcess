@echo off
cd %~dp0..
set /p IP=<IP.dat
set tool_path=c:\DiagTool
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET TestItem=Set_MFG_Mode
SET Log=SetMFGmode.log
SET log_path=%tool_path%\%log%
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat

set /a EXITCODE=255

rem del log file
del /f %log%
Tools\LANRS-Diags.exe /RD -ip %ip% -rf "%log_path%"

:Set_MFG
set /p MFGfile=<Tools\ScriptsOnTester\srqRequestID.dat
echo %MFGfile%

Tools\LANRS-diags.exe /e -ip %ip% -w -ex -f "cmd.exe /c C:\KoreDeviceServer\MfgMode\SetUefiManufacturingModeEnable.exe C:\KoreDeviceServer\MfgMode\%MFGfile%.p7b >%log_path%"
IF %ERRORLEVEL% NEQ 0 set /a exitcode=255 & GOTO Faillog

Tools\LANRS-diags.exe /Q -ip %ip% -rf "%log_path%"
if %errorlevel% neq 0 set /a EXITCODE=255 & goto Faillog

Tools\pt-diags.exe /find %log% "Successfully set UEFI MANUFACTURING_MODE:"
if %errorlevel% equ 0 set /a EXITCODE=0 & goto Passlog

:Faillog
SET EXIT_PF=FAIL
GOTO backup

:Passlog
SET EXIT_PF=PASS
set /a EXITCODE=0

:backup
IF NOT EXIST %Log% GOTO END
Tools\LogTransfer-auto.exe -nl /de -
call setdate.bat
SET DEST=%TestItem%\%datepath%\%EXIT_PF%
IF NOT EXIST %MISC%\%DEST% MKDIR %MISC%\%DEST%
Copy %Log% %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%.log

:End
EXIT /B %EXITCODE%