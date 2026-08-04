@echo on
cd %~dp0
SET MISC=C:\MISClog\_Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat
SET TestItem=%3
SET Log=temp.log

del %3.log
del %Log%

find %4 .\TypeC_Log\More_Detail_Result.txt >%3.log
rem TypeCTester\PT-diags.exe /gstr TypeCTester\More_Detail_Result.txt -sl %1 -el %2 >%3.log
rem find %4 %3.log >%Log%
find "PASS" %3.log

if %errorlevel% equ 0 goto Passlog

:Faillog
SET EXIT_PF=FAIL
SET EXITCODE=255
goto backup

:Passlog
SET EXIT_PF=PASS
SET EXITCODE=0

:backup
IF EXIST sn.dat SET /p SN=<sn.dat
IF EXIST TSRID.dat SET /p TSRID=<TSRID.dat
rem IF NOT EXIST %Log% GOTO END
IF NOT EXIST .\DeviceBridge\MISClog\TypeC_Test\%TestItem% MKDIR .\DeviceBridge\MISClog\TypeC_Test\%TestItem%
rem TypeCTester\LogTransfer-auto.exe -nl /de -
rem call setdate.bat
rem SET DEST=%TestItem%\%datepath%\%EXIT_PF%\%3
IF NOT EXIST %MISC%\%DEST% MKDIR %MISC%\%DEST%
rem Copy %Log% %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%_%4_%3.log
Copy %3.log .\DeviceBridge\MISClog\TypeC_Test\%TestItem%\%3.log
exit /b %EXITCODE%