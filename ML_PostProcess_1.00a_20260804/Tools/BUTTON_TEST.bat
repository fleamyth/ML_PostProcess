@echo on
SET MISC=C:\MISClog\_Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET TestItem=Check_Volume_%1_Button
SET Log=%TestItem%.log

IF EXIST sn.dat SET /p SN=<sn.dat
IF EXIST TSRID.dat SET /p TSRID=<TSRID.dat

cd %~dp0
del %log%
del DB_folder.log
dir /b "C:\DeviceBridgeLogs\*" | findstr /v /i /c:"GeneralJsonFiles" >DB_folder.log
FOR /F "delims=, " %%d in (DB_folder.log) do rd /s /q "C:\DeviceBridgeLogs\%%d"
if "%1" equ "Down" start Screen-diag.exe -nl /Show vd.jpg
if "%1" equ "Up" start Screen-diag.exe -nl /Show vu.jpg
Button-diag.exe /%2 >>%log%
if %errorlevel% equ 0 goto passlog

:Faillog
taskkill /im "Screen-diag.exe"
echo check DB-diag.exe >> %Log%
tasklist | find "DB-diag.exe" >> %Log%
echo check Finish >> %Log%
ping-auto.exe -nl /c 192.168.1.51 >> %Log%

set EXITCODE=255
SET EXIT_PF=FAIL
goto backup

:Passlog
taskkill /im "Screen-diag.exe"
SET EXITCODE=0
SET EXIT_PF=PASS

:backup
IF NOT EXIST .\MISClog\%TestItem% MKDIR .\MISClog\%TestItem%

copy /y %log% .\MISClog\%TestItem%\%log%
if "%EXIT_PF%" equ "FAIL" copy /y DB_initial.log .\MISClog\%TestItem%\DB_initial.log

dir /b /ad C:\DeviceBridgeLogs\%SN%* >db_log_folder.log
FOR /F "delims=, " %%l in (db_log_folder.log) do xcopy /y /s /f /q C:\DeviceBridgeLogs\%%l .\MISClog\%TestItem%\DB\%%l\

:End
EXIT /B %EXITCODE%



