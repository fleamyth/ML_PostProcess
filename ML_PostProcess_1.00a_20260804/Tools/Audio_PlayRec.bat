@echo off
cd %~dp0..
set /p IP=<IP.dat
set tool_path=c:\DiagTool
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET TestItem=Audio_playRec
SET Log=Audio_playRec.log
SET log_path=%tool_path%\%log%
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat

set /a exitcode=255

rem del log
del /f audio-diag.wav
Tools\LANRS-diags.exe /rd -ip %ip% -rf "c:\server\audio-diag.wav"

:PlayRec
rem send wav
Tools\LANRS-diags.exe /s -ip %ip% -f ".\tools\%2" -rto "%tool_path%"

Tools\LANRS-diags.exe /e -ip %ip% -w -ex -f "%tool_path%\audio-diag.exe -time %1 /playrec %tool_path%\%2"

rem get log file from DUT
Tools\LANRS-diags.exe /Q -ip %ip% -rf "c:\server\audio-diag.wav"

if exist audio-diag.wav set /a exitcode=0 & goto Passlog

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