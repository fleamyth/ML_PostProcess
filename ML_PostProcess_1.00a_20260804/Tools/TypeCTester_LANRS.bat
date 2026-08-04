@echo on
cd %~dp0
SET MISC=C:\MISClog\_Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat
SET TestItem=USB_Type_%1
call setdate.bat
SET Log=USBTypeCTester_Detail_%datepath%

if "%1" equ "C2" goto C2

cd TypeC_Log
del *.txt
rd /q /s log
rd /q /s log_csv
cd..
del %Log%
.\LANRS-Diags.exe /rd -rf C:\TypeCTester\log -ip 192.168.1.51
.\LANRS-Diags.exe /rd -rf C:\TypeCTester\Result.txt -ip 192.168.1.51
.\LANRS-Diags.exe /rd -rf C:\TypeCTester\Result.log -ip 192.168.1.51

.\LANRS-Diags.exe /e -f "taskkill /f /im TypeC2605Tester.exe" -ip 192.168.1.51
.\LANRS-Diags.exe /e -f C:\TypeCTester\TypeC2605Tester.exe -ip 192.168.1.51

.\Chopper-diag.exe /delay 60000

.\LANRS-Diags.exe /qd -rf C:\TypeCTester\log -ip 192.168.1.51 -to .\TypeC_Log\
.\LANRS-Diags.exe /q -rf C:\TypeCTester\Result.txt -ip 192.168.1.51 -to .\TypeC_Log\
.\LANRS-Diags.exe /q -rf C:\TypeCTester\Result.log -ip 192.168.1.51 -to .\TypeC_Log\

find "pass,T,M,ID4_A" TypeC_Log\Result.log
if %errorlevel% neq 0 goto Retry
find "pass,T,M,ID4_B" TypeC_Log\Result.log
if %errorlevel% neq 0 goto Retry
goto Passlog

:C2
find "pass,T,M,ID5_A" TypeC_Log\Result.log
if %errorlevel% neq 0 goto Faillog
find "pass,T,M,ID5_B" TypeC_Log\Result.log
if %errorlevel% neq 0 goto Faillog
goto Passlog

:Retry
echo retry check >> %Log%
ping-auto.exe -nl /c 192.168.1.51 >> %Log%
if %errorlevel% neq 0 goto Faillog
echo start backup >> %Log%

IF EXIST sn.dat SET /p SN=<sn.dat
IF EXIST TSRID.dat SET /p TSRID=<TSRID.dat
IF NOT EXIST .\DeviceBridge\MISClog\%TestItem%_1 MKDIR .\DeviceBridge\MISClog\%TestItem%_1
xcopy .\TypeC_Log .\DeviceBridge\MISClog\%TestItem%_1 /c /e /y
echo start retry >> %Log%

cd TypeC_Log
del *.txt
rd /q /s log
rd /q /s log_csv
cd..
.\LANRS-Diags.exe /rd -rf C:\TypeCTester\log -ip 192.168.1.51
.\LANRS-Diags.exe /rd -rf C:\TypeCTester\Result.txt -ip 192.168.1.51
.\LANRS-Diags.exe /rd -rf C:\TypeCTester\Result.log -ip 192.168.1.51

.\LANRS-Diags.exe /e -f "taskkill /f /im TypeC2605Tester.exe" -ip 192.168.1.51
.\LANRS-Diags.exe /e -f C:\TypeCTester\TypeC2605Tester.exe -ip 192.168.1.51

.\Chopper-diag.exe /delay 60000

.\LANRS-Diags.exe /qd -rf C:\TypeCTester\log -ip 192.168.1.51 -to .\TypeC_Log\
.\LANRS-Diags.exe /q -rf C:\TypeCTester\Result.txt -ip 192.168.1.51 -to .\TypeC_Log\
.\LANRS-Diags.exe /q -rf C:\TypeCTester\Result.log -ip 192.168.1.51 -to .\TypeC_Log\

find "pass,T,M,ID4_A" TypeC_Log\Result.log
if %errorlevel% neq 0 goto Faillog
find "pass,T,M,ID4_B" TypeC_Log\Result.log
if %errorlevel% neq 0 goto Faillog
goto Passlog


:Faillog
ping-auto.exe -nl /c 192.168.1.51 >> %Log%
SET EXIT_PF=FAIL
SET EXITCODE=255
goto backup

:Passlog
SET EXIT_PF=PASS
SET EXITCODE=0

:backup
rem IF NOT EXIST %Log% GOTO END
IF EXIST sn.dat SET /p SN=<sn.dat
IF EXIST TSRID.dat SET /p TSRID=<TSRID.dat
IF NOT EXIST .\DeviceBridge\MISClog\%TestItem% MKDIR .\DeviceBridge\MISClog\%TestItem%

xcopy .\TypeC_Log .\DeviceBridge\MISClog\%TestItem% /c /e /y
copy .\%Log% .\DeviceBridge\MISClog\%TestItem%\%Log%

exit /b %EXITCODE%

