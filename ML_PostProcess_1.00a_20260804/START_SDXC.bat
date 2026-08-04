@echo off

SET CSV_NAME_SD=NHK_FCT_MB_SD.csv
SET TYPE_SD=FCT_MB_SD
SET Result_SD=FAIL

copy SDSN.dat ..\SDSN.dat
IF EXIST %CSV_NAME_SD% DEL %CSV_NAME_SD%
IF EXIST .chopper RMDIR /S /Q .chopper
rem IF EXIST *.log DEL *.log
rem IF EXIST *.wav DEL *.wav
rem IF EXIST *.dat DEL *.dat
rem IF EXIST err_string.* DEL err_string.*
copy ..\op.dat op.dat
move ..\SDSN.dat SDSN.dat
:test
REM IF EXIST tid.dat Chopper-diag.exe -tidf tid.dat -c -si -opf op.dat -SNF SDSN.dat -sip -TSRID -RL -f FCT_MB_SD.xml -as -ae /r
Chopper-diag.exe -c -si -opf op.dat -SNF SDSN.dat -sip -TSRID -RL -f FCT_MB_SD.xml -as -ae  -adr /r
set errorsd=%ERRORLEVEL%
IF %errorsd% EQU 250 GOTO InteruptErr
IF %errorsd% EQU 251 GOTO InteruptErr
IF %errorsd% EQU 252 GOTO InteruptErr
IF %errorsd% EQU 253 GOTO InteruptErr
IF %errorsd% EQU 254 GOTO InteruptErr
IF %errorsd% EQU 0 GOTO Testpass
IF %errorsd% NEQ 0 GOTO TestFail

:InteruptErr
EXIT /b 253

:TestFail
SET Result_SD=FAIL
GOTO CHKTimeSync

:TestPass
SET Result_SD=PASS

:CHKTimeSync
REM SET ProductionTest=0 for offline file
IF "%MODE%" EQU "D" Tools\CSV-diag.exe /debug %CSV_NAME_SD% & GOTO Backup
IF "%SFISCONN%" NEQ "True" goto DateCHK
tzutil /s "China Standard Time" 
net time \\%SFIS_IP% /SET /y
IF %ERRORLEVEL% NEQ 0 Tools\Screen-diag.exe -nl -enter /SS 55 "Time Sync Error<br> <br>校時失敗, 請檢查連線情形或校時功能<br> <br>按[Enter]後重新嘗試校時...<br> Press [Enter] to Retry Time Sync..." 0xFFFFFF -bg 0x882222 & GOTO CHKTimeSync

:DateCHK
Tools\DateChk-auto.exe /FILE %CSV_NAME_SD%
IF %ERRORLEVEL% NEQ 0 GOTO CHKFAIL
goto Backup

:CHKFAIL
echo %date%_%time% ***(%SN%_%TSRID%)-%CSV_NAME_SD% Time Sync Error,*** >> C:\MFGlog\%TYPE_SD%log\event\_DateChkerror.log
type DateChk.log >> C:\MFGlog\%TYPE_SD%log\event\_DateChkerror.log
Tools\Screen-diag.exe -nl -enter /SS 40 "Log Time Error!!<br> <br> Log 時間差異過大 SN:%SN%<br>記錄不上傳不備份 Log Won't Upload or Backup<br> 請確認校時後重新測試 Please check time sync and retest. " 0xFFFFFF -bg 0x882222
GOTO InteruptErr

:Backup
SET Dest=C:\MFGlog\%TYPE_SD%log
IF "%MODE%" EQU "D" SET Dest=C:\MFGlog\%TYPE_SD%log\Debug
Tools\LogTransfer-auto.exe -nl -d %Dest% -F %Result_SD% /L %CSV_NAME_SD%
IF "%MODE%" EQU "D" GOTO END
IF "%Result_SD%" EQU "PASS" GOTO PASS
GOTO FAIL

:FAIL
REM Please create chariot.ok on server Chariot\log\%TYPE_SD%; it will be saved in date\tester\pass//fail
Tools\LogTransfer-auto.exe -nl -U Nighthawk_%TYPE_SD%.ok -D %on_Drive%\Log\%TYPE_SD%\ -tester -F FAIL /L %CSV_NAME_SD%
IF %ERRORLEVEL% NEQ 0 GOTO ReConnect
GOTO END

:PASS
Tools\LogTransfer-auto.exe -nl -U Nighthawk_%TYPE_SD%.ok -D %on_Drive%\Log\%TYPE_SD%\ -tester -F PASS /L %CSV_NAME_SD%
IF %ERRORLEVEL% NEQ 0 GOTO ReConnect
GOTO END

:END
IF EXIST TSRID.dat DEL TSRID.dat
IF "%Result_SD%" EQU "FAIL" EXIT /b 254
EXIT /b 0
IF "%Result_SD%" EQU "FAIL" Record-diag.exe /FAIL
IF "%Result_SD%" EQU "PASS" Record-diag.exe /PASS
IF EXIST %CSV_NAME_SD% DEL %CSV_NAME_SD% 
EXIT /b 254