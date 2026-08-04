@echo on
cd %~dp0

taskkill /f /t /im TBT01Tester.exe
del /f/ q ..\Temp\TypeC_log\TypeCtester_beforeRun.Fpc
del /f/ q ..\Temp\TypeC_log\TypeCtester_afterRun.Fpc
del /f/ q ..\Temp\TypeC_log\TypeCtester_Pass.Fpc 
rmdir /q /s logs
rmdir /q /s log
rmdir /q /s dump
rmdir /q /s ..\Temp\TypeC_log
del /f /q tbt01_detail.log
del /f /q Result.txt
del /f /q tbt.log

echo Before Run TBT01Tester.exe> ..\Temp\TypeC_log\TypeCtester_beforeRun.Fpc
CALL TBT01Tester.exe
rem E:\Diags\Jalama\Tools\TypeCTester\TBT01Tester.exe > 1.txt 2>&1
echo After Run TBT01Tester.exe> ..\Temp\TypeC_log\TypeCtester_afterRun.Fpc

dir /b /o-d logs> logname.txt
set /p logname=<logname.txt
copy /y logs\%logname% tbt01_detail.log

find /i "PASS" Result.txt
if %errorlevel% equ 0 set rtn=0& goto end
set rtn=255& goto end

rem if FAIL(device not found) return 251
find /i "device not found" tbt01_detail.log
if %errorlevel% equ 0 set rtn=251& goto end

findstr /i /c:"test Fail" tbt01_detail.log > tbt.log
if %errorlevel% neq 0 goto port1_2_fail
find /i "Port1 id = 0" tbt.log
if %errorlevel% equ 0 goto port2_chk
find /i "Port2 id = 1" tbt.log
if %errorlevel% equ 0 goto port2_fail
rem set default errorcode to 255
goto port1_2_fail

:port2_chk
find /i "Port2 id = 1" tbt.log
if %errorlevel%==0 goto port1_2_fail
goto port1_fail

:port1_fail
echo TypeC Port1_fail
set rtn=253& goto end

:port2_fail
echo TypeC Port2_fail
set rtn=254& goto end

:port1_2_fail
echo TypeC Port1_Port2_fail
set rtn=255& goto end

:end
xcopy /c /y /e /i log ..\Temp\TypeC_log
xcopy /c /y /e /i logs ..\Temp\TypeC_log
xcopy /c /y /e dump ..\Temp\TypeC_log
copy /y result.txt ..\Temp\TypeC_log
copy /y *.Fpc ..\Temp\TypeC_log
xcopy /c /y /e log ..\Temp\TypeC_log

xcopy /c /y /e logs ..\Temp\TypeC_log
copy /y logs\xml\TBT-result.xml ..\Temp\TypeC_log\TBT01_TBT-result.xml
copy /y result.txt ..\Temp\TypeC_log\TBT01_result.txt

if %rtn%==0 echo Pass> ..\Temp\TypeC_log\TypeCtester_Pass.Fpc & exit /b 0
exit /b %rtn%