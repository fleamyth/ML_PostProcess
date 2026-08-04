REM Program Description
REM Copyright by Pegatron, Build Date:2016-11-02 Rev1.01f, Diagnostics
REM ============================================================
@echo on
IF /I "%~1"=="__UPLOAD_GRR_WORKER" GOTO UPLOAD_GRR_WORKER
IF EXIST op.dat DEL op.dat
REM ===== Version Setting =====
SET Ver=1.00a
SET DateVer=20260804
REM ===========================
SET TYPE=%1
SET MODE=%2
SET TEST_MODE=Online
IF "%MODE%" EQU "D" SET TEST_MODE=Offline
SET PROJECT=ML
SET SUITE_NAME=ML_PostProcess
SET BUILD=MP
SET CSV_NAME=%PROJECT%_%TYPE%.csv
SET CFG_NAME=config.xml
IF "%DebugXML%" equ "True" SET CFG_NAME=config_Deb.xml
SET SN_LEN=12
SET FOLDER=%SUITE_NAME%_%Ver%_%DateVer%
SET on_Drive=N:
SET SFIS_IP=172.24.248.128
SET Connect=FALSE
SET "GOOGLE_DRIVE_URL=https://drive.google.com/drive/folders/1VuN9N7JXBBuHByXVgUjm1jEw18wSW_N6"
SET "GOOGLE_DRIVE_UPLOAD_BAT=%~dp0%FOLDER%\Tools\upload_Folder_to_google_drive.bat"
FOR /F "usebackq delims=" %%P IN (`powershell.exe -NoProfile -Command "[Environment]::GetEnvironmentVariable('Path','Machine')+';'+[Environment]::GetEnvironmentVariable('Path','User')"`) DO SET "PATH=%%P"
SET "DESKTOP_DIR="
FOR /F "usebackq delims=" %%D IN (`powershell.exe -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"`) DO SET "DESKTOP_DIR=%%D"
IF NOT DEFINED DESKTOP_DIR SET "DESKTOP_DIR=%USERPROFILE%\Desktop"
SET "LOG_ROOT=%DESKTOP_DIR%\logs"
SET "LOG_ARCHIVE_ROOT=D:\logs"
SET /a SCAN=0

:START_OP
IF NOT EXIST C:\MFGlog\%TYPE%log\event mkdir C:\MFGlog\%TYPE%log\event
IF EXIST MISClog.dat DEL MISClog.dat
IF "%MODE%" NEQ "D" ECHO C:\MISClog>MISClog.dat

SET Result=
cd %~dp0
IF EXIST %CSV_NAME% DEL %CSV_NAME%
IF EXIST *KoreVer.log DEL *KoreVer.log
IF EXIST PN.log DEL PN.log
IF EXIST PN.txt DEL PN.txt
IF EXIST op.dat GOTO START

DiagPGM\Chopper-diag.exe /SB "^[Ss][0-9]{2}[0-9,AaBbCc][0-9]{5}$" -SIF op.jpg -EMF sb_msg_OP.msgdat -SFN ..\OP.dat -FS 30 -st "Please scan operator number\nPlease Enter Operator Number" -sbsize 800 300
IF %ERRORLEVEL% NEQ 0 GOTO START_OP

:START
DiagPGM\Screen-diag.exe -nl -enter /SS 55 "<br>Please connect the device.<br> <br>Press [Enter] to start the test." 0xFFFFFF -bg 0x223366

adb get-state 2>nul | findstr /X /C:"device" >nul
IF %ERRORLEVEL% NEQ 0 GOTO START

SET ScanTime=0

:GetDutSN
REM Get SN from DUT
IF EXIST SN.dat DEL SN.dat

REM Make sure the DUT is connected over adb, then read its serial number.
adb wait-for-device
TIMEOUT 1

SET "DUT_SN="
FOR /F "usebackq delims=" %%S IN (`adb get-serialno 2^>nul`) DO SET "DUT_SN=%%S"

REM Retry if no valid serial was returned.
IF NOT DEFINED DUT_SN GOTO GetDutSN
IF /I "%DUT_SN%"=="unknown" GOTO GetDutSN

REM Ensure the serial number is exactly 12 characters.
IF NOT "%DUT_SN:~12%"=="" GOTO GetDutSN
IF "%DUT_SN:~11,1%"=="" GOTO GetDutSN

ECHO %DUT_SN%>SN.dat

IF %ERRORLEVEL% EQU 0 GOTO SetVar
GOTO GetDutSN

:setvar
IF EXIST OP.dat SET /p OP=<OP.dat
IF EXIST SN.dat SET /p SN=<SN.dat
SET "LOG_IDENTIFIER="
FOR /F "usebackq delims=" %%H IN (`adb shell getprop ro.serialno 2^>nul`) DO SET "LOG_IDENTIFIER=%%H"
IF NOT DEFINED LOG_IDENTIFIER SET "LOG_IDENTIFIER=%SN%"
COPY OP.dat DiagPGM\OP.dat
COPY SN.dat DiagPGM\SN.dat

IF NOT EXIST %on_Drive% net use /delete %on_Drive%

:chkroute
python RESTSFIS-diag\RESTSFIS-diag.py /C -sn %SN%
IF %ERRORLEVEL% EQU 0 GOTO Non_TID
GOTO CRfail

:CRfail
REM Check Route Fail
DiagPGM\Screen-diag.exe -nl -enter /SS 55 "SFIS Error - Check Route Failure !!<br>Please check DUT route status !! <br>See SFISLOG\YYYYMMDD.log for details.<br>OP: %op% <br> SN: %SN%" 0xFFFFFF -bg 0x882222
GOTO InteruptErr

:Non_TID
SET tid=NOTID
echo NOTID>tid.dat

:getconfig
IF "%SFISCONN%" EQU "True" Call config.bat 1 online %FOLDER%
IF "%SFISCONN%" NEQ "True" Call config.bat 1 offline %FOLDER%
IF "%SFISCONN%" NEQ "True" GOTO NoSFISTid
GOTO clean
:NoSFISTid
echo Debug>tid.dat

:clean
IF EXIST %FOLDER% GOTO enterTS
DiagPGM\Screen-diag.exe -enter /ss 50 "Please check folder "%FOLDER%" exist <br> <br>Press [Enter] to Jig Up" 0xFFFFFF -bg 0xFF0000
GOTO InteruptErr

:enterTS
rd /s /q %FOLDER%\TypeCTester\log_csv\
rd /s /q %FOLDER%\TypeCTester\log\
cd %~dp0
cd %FOLDER%
rd /s /q Tools\DeviceBridge\MISClog

rmdir /s /q Tools\Temp
rd /s /q Tools\MISClog

if not exist Tools\Temp mkdir Tools\Temp

del online.flg
IF "%DebugXML%" neq "True" echo flg > online.flg
IF "%DebugXML%" equ "True" echo debug>debug.flg
IF EXIST %CSV_NAME% DEL %CSV_NAME%
IF EXIST .chopper RMDIR /S /Q .chopper
IF EXIST *.log DEL *.log
IF EXIST *.wav DEL *.wav
IF EXIST *.dat DEL *.dat
IF EXIST deviceID.ini DEL deviceID.ini
IF EXIST err_string.* DEL err_string.*
move ..\*.dat .
copy op.dat ..
copy ..\Config.ini .
copy ..\deviceID.ini .

:test
set /p SN=<SN.dat

echo %SN%>SN.DAT
cd %~dp0%FOLDER%
IF DEFINED TEST_RUN_MARKER DEL /Q "%TEST_RUN_MARKER%" 2>nul
SET "TEST_RUN_MARKER=%TEMP%\ML_PostProcess_run_%RANDOM%_%RANDOM%.tmp"
TYPE NUL >"%TEST_RUN_MARKER%"
Chopper-diag.exe -NoHotKey -LD TcsTestSuiteDuration %PROJECT% -c -si -CGV -opf op.dat -SNF SN.dat -sip -TSRID -lock -RL -f %CFG_NAME% -as -ae -SNP "^[0-9,A-Z]{%SN_LEN%}$" -tidf tid.dat -lf ..\DiagPGM\tidlog.xml /r
IF %ERRORLEVEL% EQU 0 GOTO TestPass
IF %ERRORLEVEL% EQU 255 GOTO TestFail
IF %ERRORLEVEL% NEQ 0 pause
IF %ERRORLEVEL% EQU 250 GOTO InteruptErr
IF %ERRORLEVEL% EQU 251 GOTO InteruptErr
IF %ERRORLEVEL% EQU 252 GOTO InteruptErr
IF %ERRORLEVEL% EQU 253 GOTO InteruptErr
IF %ERRORLEVEL% EQU 254 GOTO InteruptErr

:InteruptErr
ECHO Interupt Error
GOTO START

:TestFail
find /i "%PROJECT%,80" %CSV_NAME%
IF %ERRORLEVEL% equ 0 goto ShowFail
find /i "%PROJECT%,8F" %CSV_NAME%
IF %ERRORLEVEL% equ 0 goto ShowFail
find /i "%PROJECT%,C" %CSV_NAME%
IF %ERRORLEVEL% equ 0 goto ShowFail
find /i "%PROJECT%,N" %CSV_NAME%
IF %ERRORLEVEL% equ 0 goto ShowFail
find /i "%PROJECT%,M" %CSV_NAME%
IF %ERRORLEVEL% equ 0 goto ShowFail
cls
call Screen-diag.exe -enter /ss 70 "unexpected exit or unknow error code happens." 0xFFFFFF -bg 0xBB2222
goto START

:ShowFail
SET Result=FAIL

cd %~dp0%FOLDER%
Tools\UILogResult-auto.exe -log %CSV_NAME% /F
CALL :UPLOAD_GRR_AND_WAIT_DUT_DISCONNECT
GOTO jigup

:TestPass
cd %~dp0
cd %FOLDER%
SET Result=PASS

:jigup
SET /p TSRID=<TSRID.dat
cd %~dp0%FOLDER%

:DateCHK
Tools\DateChk-auto.exe /FILE %CSV_NAME%
IF %ERRORLEVEL% NEQ 0 GOTO CHKFAIL
goto Backup

:CHKFAIL
echo %date%_%time% ***(%SN%_%TSRID%)-%CSV_NAME% Time Sync Error,*** >> C:\MFGlog\%TYPE%log\event\_DateChkerror.log
type DateChk.log >> C:\MFGlog\%TYPE%log\event\_DateChkerror.log
Tools\Screen-diag.exe -nl -enter /SS 40 "Log Time Error!!<br> <br> Log time is out of sync for SN:%SN%<br>This log will not upload or back up.<br> Please check time sync and retest." 0xFFFFFF -bg 0x882222
GOTO InteruptErr

:Backup
LogTransfer-auto.exe -nl /de
call setdate.bat
SET Dest=C:\MFGlog\%TYPE%log\Online
SET MISC=C:\MISClog\%PROJECT%\%BUILD%\Online\%datepath%\%Result%
SET /p TSRID=<TSRID.dat
IF "%MODE%" EQU "D" SET Dest=C:\MFGlog\%TYPE%log\Debug
IF "%MODE%" EQU "D" SET MISC=C:\MISClog\%PROJECT%\%BUILD%\Debug\%datepath%\%Result%

COPY /y /v %CSV_NAME% .\tools\Temp\

cd tools
del .\MISCLog.zip

rename temp MISCLog
7z\7za.exe a -tzip .\MISCLog.zip .\MISCLog
IF NOT EXIST %MISC% MKDIR %MISC%
copy /y .\MISCLog.zip %MISC%\%SN%_%TSRID%.zip

cd..
Tools\LogTransfer-auto.exe -nl /L %CSV_NAME%
IF "%MODE%" EQU "D" GOTO END
cd %~dp0%FOLDER%

IF %Result% EQU FAIL goto DUT1_UP_fail
Tools\LogTransfer-auto.exe -nl  -tester -F PASS /L %CSV_NAME%
goto SFIS_UP
:DUT1_UP_fail
Tools\LogTransfer-auto.exe -nl  -tester -F FAIL /L %CSV_NAME%

:SFIS_UP
SET SFISerror=0

:SFIS
python RESTSFIS-diag.py /UP -log %CSV_NAME%
IF %ERRORLEVEL% NEQ 0 GOTO SFIS_fail
GOTO END

:SFIS_FAIL
SET /a SFISerror=%SFISerror% + 1
echo SFIS Upload Fail
Tools\Screen-diag.exe -nl -enter /ss 70 "SFIS Upload FAIL(%SFISerror%)! <br> <br>Please Check SFIS!<br> <br>Press [Enter] to Retry"  0xFFFFFF -bg 0xBB2222
GOTO SFIS

:END
IF "%Result%" NEQ "PASS" GOTO Record
IF EXIST TSRID.dat DEL TSRID.dat
Tools\Screen-diag.exe -nl -enter /ss 200 "PASS"  0xFFFFFF -bg 0x008800
Chopper-diag.exe /delay 500 2>nul
taskkill /IM Screen-diag.exe

CALL :UPLOAD_GRR_AND_WAIT_DUT_DISCONNECT
GOTO Record

:UPLOAD_GRR_AND_WAIT_DUT_DISCONNECT
REM Move this run's logs to D:\logs first, then upload that folder to Google Drive.
CALL :ARCHIVE_COMPLETED_LOGS
SET "LOG_ARCHIVE_RESULT=%ERRORLEVEL%"
DEL /Q "%TEST_RUN_MARKER%" 2>nul
SET "TEST_RUN_MARKER="
IF NOT "%LOG_ARCHIVE_RESULT%" EQU "0" EXIT /B 1
SET "GOOGLE_DRIVE_UPLOAD_STATUS=%TEMP%\ML_PostProcess_gdrive_status_%RANDOM%_%RANDOM%.tmp"
DEL /Q "%GOOGLE_DRIVE_UPLOAD_STATUS%" "%GOOGLE_DRIVE_UPLOAD_STATUS%.new" 2>nul
START "" /B CMD.EXE /D /C CALL "%~f0" __UPLOAD_GRR_WORKER
IF %ERRORLEVEL% NEQ 0 >"%GOOGLE_DRIVE_UPLOAD_STATUS%" ECHO 1
CALL :WAIT_FOR_UPLOAD_AND_DUT_DISCONNECT

:WAIT_GOOGLE_DRIVE_UPLOAD
IF NOT EXIST "%GOOGLE_DRIVE_UPLOAD_STATUS%" (
	TIMEOUT /T 1 /NOBREAK >nul
	GOTO WAIT_GOOGLE_DRIVE_UPLOAD
)
SET "GOOGLE_DRIVE_UPLOAD_EXITCODE=1"
SET /P GOOGLE_DRIVE_UPLOAD_EXITCODE=<"%GOOGLE_DRIVE_UPLOAD_STATUS%"
DEL /Q "%GOOGLE_DRIVE_UPLOAD_STATUS%" 2>nul
SET "GOOGLE_DRIVE_UPLOAD_STATUS="
IF NOT "%GOOGLE_DRIVE_UPLOAD_EXITCODE%" EQU "0" GOTO GOOGLE_DRIVE_UPLOAD_ERROR
EXIT /B 0

:GOOGLE_DRIVE_UPLOAD_ERROR
Tools\Screen-diag.exe -nl -enter /SS 40 "Google Drive upload FAIL!!<br><br>Log ID: %LOG_IDENTIFIER%<br>Please check rclone and network settings.<br><br>Press [Enter] to continue." 0xFFFFFF -bg 0x882222
EXIT /B 1

:WAIT_FOR_UPLOAD_AND_DUT_DISCONNECT
START "" Tools\Screen-diag.exe -nl /SS 55 "Please disconnect the device from the computer.<br><br>Google Drive upload is running..." 0xFFFFFF -bg 0xFF7F25
TIMEOUT /T 1 /NOBREAK >nul
SET "GOOGLE_DRIVE_UPLOAD_COMPLETE="
SET "DUT_DISCONNECTED="

:WAIT_FOR_UPLOAD_AND_DUT_DISCONNECT_CHECK
IF NOT DEFINED GOOGLE_DRIVE_UPLOAD_COMPLETE IF EXIST "%GOOGLE_DRIVE_UPLOAD_STATUS%" (
	SET "GOOGLE_DRIVE_UPLOAD_COMPLETE=TRUE"
	SET "GOOGLE_DRIVE_UPLOAD_EXITCODE=1"
	SET /P GOOGLE_DRIVE_UPLOAD_EXITCODE=<"%GOOGLE_DRIVE_UPLOAD_STATUS%"
)
IF DEFINED GOOGLE_DRIVE_UPLOAD_COMPLETE IF NOT "%GOOGLE_DRIVE_UPLOAD_EXITCODE%" EQU "0" (
	taskkill /IM Screen-diag.exe
	EXIT /B 0
)

SET "ADB_DEVICE_CONNECTED="
adb devices >"%TEMP%\ML_PostProces_adb_devices.tmp" 2>nul
IF %ERRORLEVEL% EQU 0 FOR /F "usebackq skip=1 tokens=1" %%A IN ("%TEMP%\ML_PostProces_adb_devices.tmp") DO SET "ADB_DEVICE_CONNECTED=TRUE"
DEL /Q "%TEMP%\ML_PostProces_adb_devices.tmp" 2>nul
IF NOT DEFINED ADB_DEVICE_CONNECTED SET "DUT_DISCONNECTED=TRUE"

IF DEFINED GOOGLE_DRIVE_UPLOAD_COMPLETE IF DEFINED DUT_DISCONNECTED (
	taskkill /IM Screen-diag.exe
	EXIT /B 0
)
TIMEOUT /T 1 /NOBREAK >nul
GOTO WAIT_FOR_UPLOAD_AND_DUT_DISCONNECT_CHECK

:ARCHIVE_COMPLETED_LOGS
IF /I "%TYPE%"=="RoboCal" GOTO ARCHIVE_COMPLETED_LOGS_RUN
IF /I "%TYPE%"=="Post" GOTO ARCHIVE_COMPLETED_LOGS_RUN
IF /I "%TYPE%"=="PostProcess" GOTO ARCHIVE_COMPLETED_LOGS_RUN
EXIT /B 0

:ARCHIVE_COMPLETED_LOGS_RUN
SET "LOG_ARCHIVE_SOURCE=%LOG_ROOT%\%LOG_IDENTIFIER%"
SET "LOG_ARCHIVE_DESTINATION=%LOG_ARCHIVE_ROOT%\%LOG_IDENTIFIER%\Robocal"
SET "LOG_ARCHIVE_ROBOCOPY_LOG=%TEMP%\ML_PostProces_archive_%RANDOM%_%RANDOM%.log"
IF NOT EXIST "%LOG_ARCHIVE_DESTINATION%\" MKDIR "%LOG_ARCHIVE_DESTINATION%" 2>nul
IF NOT EXIST "%LOG_ARCHIVE_DESTINATION%\" GOTO ARCHIVE_COMPLETED_LOGS_FAIL
CALL :ARCHIVE_LOG_COMPONENT DGC
IF %ERRORLEVEL% NEQ 0 GOTO ARCHIVE_COMPLETED_LOGS_FAIL
CALL :ARCHIVE_LOG_COMPONENT DCC
IF %ERRORLEVEL% NEQ 0 GOTO ARCHIVE_COMPLETED_LOGS_FAIL
IF NOT EXIST "%LOG_ARCHIVE_SOURCE%\" GOTO ARCHIVE_CURRENT_ROBOCAL_OUTPUT

REM Copy (tolerant of logs RoboCal may still hold open), then remove the source best-effort.
ROBOCOPY "%LOG_ARCHIVE_SOURCE%" "%LOG_ARCHIVE_DESTINATION%" /E /R:3 /W:5 /NFL /NDL /NJH /NJS /NP >"%LOG_ARCHIVE_ROBOCOPY_LOG%"
SET "LOG_ARCHIVE_EXITCODE=%ERRORLEVEL%"
IF %LOG_ARCHIVE_EXITCODE% GEQ 8 GOTO ARCHIVE_COMPLETED_LOGS_FAIL
DEL /Q "%LOG_ARCHIVE_ROBOCOPY_LOG%" 2>nul
RD /S /Q "%LOG_ARCHIVE_SOURCE%" 2>nul

:ARCHIVE_CURRENT_ROBOCAL_OUTPUT
SET "ROBOCAL_OUTPUT_SOURCE=%LOG_ROOT%\robocal_output"
SET "ROBOCAL_OUTPUT_DESTINATION=%LOG_ARCHIVE_DESTINATION%"
SET "ROBOCAL_OUTPUT_ARCHIVE_COUNT=0"
SET "ROBOCAL_OUTPUT_ARCHIVE_COUNT_FILE=%TEMP%\ML_PostProces_robocal_count_%RANDOM%_%RANDOM%.tmp"
IF NOT EXIST "%TEST_RUN_MARKER%" EXIT /B 0
DEL /Q "%ROBOCAL_OUTPUT_ARCHIVE_COUNT_FILE%" 2>nul
powershell.exe -NoProfile -Command "$marker=(Get-Item -LiteralPath $env:TEST_RUN_MARKER).LastWriteTimeUtc; $source=$env:ROBOCAL_OUTPUT_SOURCE; $destination=$env:ROBOCAL_OUTPUT_DESTINATION; $count=0; $failed=$false; if(Test-Path -LiteralPath $source){foreach($file in Get-ChildItem -LiteralPath $source -Recurse -File){if(($file.Name -like 'log_file_*.log' -or $file.Name -like 'log_file_*.txt') -and $file.LastWriteTimeUtc -ge $marker){$relative=$file.FullName.Substring($source.Length).TrimStart('\'); $target=Join-Path $destination $relative; try{New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force -ErrorAction Stop | Out-Null; Copy-Item -LiteralPath $file.FullName -Destination $target -Force -ErrorAction Stop; $archived=Get-Item -LiteralPath $target -ErrorAction Stop; if($archived.Length -ne $file.Length){throw 'Archived file size does not match the source'}; $count++}catch{Write-Error ('Failed to archive ' + $file.FullName + ': ' + $_.Exception.Message); $failed=$true}}}}; Set-Content -LiteralPath $env:ROBOCAL_OUTPUT_ARCHIVE_COUNT_FILE -Value $count -NoNewline; if($failed){exit 1}"
SET "ROBOCAL_OUTPUT_ARCHIVE_EXITCODE=%ERRORLEVEL%"
IF EXIST "%ROBOCAL_OUTPUT_ARCHIVE_COUNT_FILE%" SET /P ROBOCAL_OUTPUT_ARCHIVE_COUNT=<"%ROBOCAL_OUTPUT_ARCHIVE_COUNT_FILE%"
DEL /Q "%ROBOCAL_OUTPUT_ARCHIVE_COUNT_FILE%" 2>nul
IF NOT "%ROBOCAL_OUTPUT_ARCHIVE_EXITCODE%" EQU "0" (
	SET "LOG_ARCHIVE_SOURCE=%ROBOCAL_OUTPUT_SOURCE%"
	EXIT /B 1
)
EXIT /B 0

:ARCHIVE_LOG_COMPONENT
SET "LOG_ARCHIVE_COMPONENT_SOURCE=%LOG_ARCHIVE_ROOT%\%LOG_IDENTIFIER%\%~1"
IF NOT EXIST "%LOG_ARCHIVE_COMPONENT_SOURCE%\" EXIT /B 0
ROBOCOPY "%LOG_ARCHIVE_COMPONENT_SOURCE%" "%LOG_ARCHIVE_DESTINATION%\%~1" /E /MOVE /R:3 /W:5 /NFL /NDL /NJH /NJS /NP >"%LOG_ARCHIVE_ROBOCOPY_LOG%"
SET "LOG_ARCHIVE_EXITCODE=%ERRORLEVEL%"
IF %LOG_ARCHIVE_EXITCODE% GEQ 8 (
	SET "LOG_ARCHIVE_SOURCE=%LOG_ARCHIVE_COMPONENT_SOURCE%"
	EXIT /B 1
)
DEL /Q "%LOG_ARCHIVE_ROBOCOPY_LOG%" 2>nul
EXIT /B 0

:ARCHIVE_COMPLETED_LOGS_FAIL
Tools\Screen-diag.exe -nl -enter /SS 40 "Log archive FAIL!!<br><br>Source: %LOG_ARCHIVE_SOURCE%<br>Destination: %LOG_ARCHIVE_DESTINATION%<br>See %LOG_ARCHIVE_ROBOCOPY_LOG% for details.<br><br>Press [Enter] to continue." 0xFFFFFF -bg 0x882222
EXIT /B 1

:WAIT_DUT_DISCONNECT
START "" Tools\Screen-diag.exe -nl /SS 55 "Please disconnect the device from the computer.<br><br>Waiting for ADB device disconnection..." 0xFFFFFF -bg 0xFF7F25
TIMEOUT /T 1 /NOBREAK >nul

:WAIT_DUT_DISCONNECT_CHECK
SET "ADB_DEVICE_CONNECTED="
adb devices >"%TEMP%\ML_PostProces_adb_devices.tmp" 2>nul
IF %ERRORLEVEL% NEQ 0 GOTO WAIT_DUT_DISCONNECT_RETRY
FOR /F "usebackq skip=1 tokens=1" %%A IN ("%TEMP%\ML_PostProces_adb_devices.tmp") DO SET "ADB_DEVICE_CONNECTED=TRUE"
DEL /Q "%TEMP%\ML_PostProces_adb_devices.tmp" 2>nul
IF DEFINED ADB_DEVICE_CONNECTED GOTO WAIT_DUT_DISCONNECT_RETRY
taskkill /IM Screen-diag.exe
EXIT /B 0

:WAIT_DUT_DISCONNECT_RETRY
DEL /Q "%TEMP%\ML_PostProces_adb_devices.tmp" 2>nul
TIMEOUT /T 1 /NOBREAK >nul
GOTO WAIT_DUT_DISCONNECT_CHECK

:UPLOAD_GRR_TO_GOOGLE_DRIVE
SET "GOOGLE_DRIVE_UPLOAD_FAILED=0"
SET "GOOGLE_DRIVE_SOURCE=%LOG_ARCHIVE_ROOT%\%LOG_IDENTIFIER%"
IF NOT EXIST "%GOOGLE_DRIVE_SOURCE%\" ECHO Google Drive folder upload skipped: "%GOOGLE_DRIVE_SOURCE%" does not exist.
IF NOT EXIST "%GOOGLE_DRIVE_SOURCE%\" GOTO GOOGLE_DRIVE_UPLOAD_FINISH
CALL "%GOOGLE_DRIVE_UPLOAD_BAT%" "%GOOGLE_DRIVE_SOURCE%" "%GOOGLE_DRIVE_URL%"
IF %ERRORLEVEL% NEQ 0 SET "GOOGLE_DRIVE_UPLOAD_FAILED=1"

:GOOGLE_DRIVE_UPLOAD_FINISH
IF "%GOOGLE_DRIVE_UPLOAD_FAILED%" EQU "0" EXIT /B 0
IF DEFINED GOOGLE_DRIVE_UPLOAD_BACKGROUND EXIT /B 1

Tools\Screen-diag.exe -nl -enter /SS 40 "Google Drive upload FAIL!!<br><br>Log ID: %LOG_IDENTIFIER%<br>Please check rclone and network settings.<br><br>Press [Enter] to continue." 0xFFFFFF -bg 0x882222
EXIT /B 1

:UPLOAD_GRR_WORKER
SET "GOOGLE_DRIVE_UPLOAD_BACKGROUND=1"
CALL :UPLOAD_GRR_TO_GOOGLE_DRIVE
>"%GOOGLE_DRIVE_UPLOAD_STATUS%.new" ECHO %ERRORLEVEL%
MOVE /Y "%GOOGLE_DRIVE_UPLOAD_STATUS%.new" "%GOOGLE_DRIVE_UPLOAD_STATUS%" >nul
EXIT /B 0

:Record
IF "%MODE%" EQU "D" GOTO Record1
cd %~dp0
if exist %CSV_NAME% del %CSV_NAME%
copy %FOLDER%\%CSV_NAME% %CSV_NAME%

:Record1
cd %~dp0
IF "%MODE%" EQU "D" GOTO START

:chk2Aroute
IF "%Result%" EQU "PASS" GOTO START
Start DiagPGM\Screen-diag.exe -enter /SS 55 "Checking SN %SN% SFIS 2A status<br>Please wait... <br> <br>Checking 2A Status from SFIS<br>Please wait a moment..." 0xFFFFFF -bg 0x223366
python RESTSFIS-diag\RESTSFIS-diag.py /C -sn %SN%
IF %ERRORLEVEL% EQU 0 DiagPGM\Screen-diag.exe -enter /SS 40 "SN (2A) not allowed!!<br> <br>Please change another tester to do SN (2A) test!!<br><br>Press [ENTER] to continue..." 0xFFFFFF -bg 0x773399
taskkill /IM Screen-diag.exe
GOTO START
