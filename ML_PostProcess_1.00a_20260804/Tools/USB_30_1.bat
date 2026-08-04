@echo on
cd %~dp0..
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat
SET TestItem=USB_%1_%3_%4
SET Log=USB_%1_%3.log
IF EXIST sn.dat SET /p SN=<sn.dat
IF EXIST TSRID.dat SET /p TSRID=<TSRID.dat


del %log%
del usbv.log


:USB30
tools\Diagtool\USBV-diags.exe -o -q /Save usbv.log

find "%2" usbv.log >USB_%1_%3.log
find "FailedEnumeration" USB_%1_%3.log
if %errorlevel% equ 0 goto Faillog
find "%4" USB_%1_%3.log
if %errorlevel% equ 0 goto Passlog

:Faillog
SET EXIT_PF=FAIL
GOTO Fbackup

:Passlog
SET EXIT_PF=PASS

:Pbackup
rem IF NOT EXIST %Log% GOTO END
tools\LogTransfer-auto.exe -nl /de -
call setdate.bat
SET DEST=%TestItem%\%datepath%\%EXIT_PF%
IF NOT EXIST %MISC%\%DEST% MKDIR %MISC%\%DEST%
Copy %Log% %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%_%3.log
Copy usbv.log %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%_USBALL_%3.log

:End
EXIT /B 0

:Fbackup
rem IF NOT EXIST %Log% GOTO END
tools\LogTransfer-auto.exe -nl /de -
call setdate.bat
SET DEST=%TestItem%\%datepath%\%EXIT_PF%
IF NOT EXIST %MISC%\%DEST% MKDIR %MISC%\%DEST%
Copy %Log% %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%_%3.log
Copy usbv.log %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%_USBALL_%3.log

:End
EXIT /B 255