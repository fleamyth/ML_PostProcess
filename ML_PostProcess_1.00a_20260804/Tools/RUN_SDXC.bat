@echo off
cd %~dp0
SET CSV_NAME_SD=Cairns_FCT_MB_SD.csv
SET TYPE_SD=FCT_MB_SD
SET Result_SD=FAIL

copy ..\SDSN.dat SDSN.dat
copy ..\op.dat %~dp0\op.dat
copy ..\IP.dat IP.dat
IF EXIST %CSV_NAME_SD% DEL %CSV_NAME_SD%
IF EXIST ..\%CSV_NAME_SD% DEL ..\%CSV_NAME_SD%
IF EXIST .chopper RMDIR /S /Q .chopper

:test
Chopper-diag.exe -c -si -opf op.dat -SNF SDSN.dat -RL -f FCT_MB_SD.xml -as -ae  -adr -minh /r
set errorsd=%ERRORLEVEL%
IF %errorsd% EQU 0 GOTO Testpass
IF %errorsd% NEQ 0 GOTO TestFail

:TestFail
SET Result_SD=FAIL
echo FAIL>SD.DAT
GOTO BACKUP

:TestPass
SET Result_SD=PASS
echo PASS>SD.DAT

:Backup
copy %CSV_NAME_SD% ..\%CSV_NAME_SD%
copy SD.DAT ..\SD.DAT
SET Dest=C:\MFGlog\%TYPE_SD%log
IF exist ..\DBUG.DAT SET Dest=C:\MFGlog\%TYPE_SD%log\Debug
IF "%MODE%" EQU "D" SET Dest=C:\MFGlog\%TYPE_SD%log\Debug
LogTransfer-auto.exe -nl -d %Dest% -F %Result_SD% /L %CSV_NAME_SD%
GOTO END

:END
COPY SD.DAT ..\SD.DAT
IF "%Result_SD%" EQU "FAIL" EXIT /b 255
EXIT /b 0