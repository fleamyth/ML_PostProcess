@echo off
cd %~dp0..
set /p IP=<IP.dat
set tool_path=c:\DiagTool
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET TestItem=MemVid_%1
SET Log=MemVid_%1.log
SET log_path=%tool_path%\%log%
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat

set /a exitcode=255

del /f %log%
del /f MemVid_%1_man.log
Tools\LANRS-diags.exe /rd -ip %ip% -rf "%log_path%"

:MemVid
set /a num=%1-1
set /p Memvid=<Mem%num%_VID.dat

Tools\LANRS-diags.exe /e -ip %ip% -w -ex -f "cmd.exe /c %tool_path%\DMI-diags.exe -type 11 -handle %1 /RDMI >%log_path%"
rem set /a exitcode=%errorlevel%

rem get log file from DUT
Tools\LANRS-diags.exe /Q -ip %ip% -rf "%log_path%"

rem modify log file
tools\PT-diags.exe -nl /find %log% "Manufacturer" > MemVid_%1_man.log

tools\PT-diags.exe -nl /find MemVid_%1_man.log "%Memvid%"
set /a exitcode=%errorlevel%

if %exitcode% equ 0 goto Passlog

:Faillog
SET EXIT_PF=FAIL
GOTO backup

:Passlog
SET EXITCODE=0
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
