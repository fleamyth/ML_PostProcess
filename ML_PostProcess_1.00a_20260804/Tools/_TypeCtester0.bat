
@echo oN

cd %~dp0

rem Call TypeC test process in DUT

LANRS-Diags.exe /E -ip 192.168.1.51 -f "E:\Diags\Jalama\Tools\TypeCtester0\_TypeC_DUT_TBT01.bat" -w -ex -timeout 120
if %errorlevel% neq 0 goto fail

rem Copy Log from DUT 
REM .\LANRS-Diags.exe /QD -ip 192.168.1.51 -rf "E:\Diags\Jalama\Tools\Temp" -to "." -w -e 0 -timeout 30

mkdir .\Temp\TypeC0_log_%TypeC_TestItems_Count%_pass
.\LANRS-Diags.exe /QD -ip 192.168.1.51 -rf "E:\Diags\Jalama\Tools\Temp\TypeC_log0" -to ".\Temp\TypeC0_log_%TypeC_TestItems_Count%_pass" -w -e 0 -timeout 30

exit /b 0 


:fail
SET /a typeCerr=%errorlevel%

rem Copy Log from DUT 
REM .\LANRS-Diags.exe /QD -ip 192.168.1.51 -rf "E:\Diags\Jalama\Tools\Temp" -to "." -w -e 0 -timeout 30

mkdir .\Temp\TypeC0_log_%TypeC_TestItems_Count%_fail
.\LANRS-Diags.exe /QD -ip 192.168.1.51 -rf "E:\Diags\Jalama\Tools\Temp\TypeC_log0" -to ".\Temp\TypeC0_log_%TypeC_TestItems_Count%_fail" -w -e 0 -timeout 30


rem Plug out type_C和USB3.0 cable
REM KING-diags.exe -com 2 -br 9600 -f a41.txt  /sb 55 AA 01 80 80
REM timeout 1

REM turn off 20V power
REM King-diags.exe -com 2 -br 9600 -f 20Vpower_off.txt /sb 55 AA 01 A0 A0
REM King-diags.exe -com 2 -br 9600 -f 20Vpower_off.txt /sb 55 AA 01 B0 B0
REM timeout 1

REM turn on 20V power
REM King-diags.exe -com 2 -br 9600 -f 20Vpower.txt /sb 55 AA 01 A1 A1
REM King-diags.exe -com 2 -br 9600 -f 20Vpower.txt /sb 55 AA 01 B1 B1
REM timeout 1

REM Plug in type_C和USB3.0 cable
REM KING-diags.exe -com 2 -br 9600 -f a31.txt  /sb 55 AA 01 81 81
REM timeout 2

rem if not exist log file return 252
rem if FAIL(device not found) return 251
if %typeCerr%==255 exit /b 255
if %typeCerr%==254 exit /b 254
if %typeCerr%==253 exit /b 253
if %typeCerr%==252 goto showlogfail
if %typeCerr%==251 exit /b 251
exit /b 255

:showlogfail
Screen-diag.exe -nl -enter /SS 55 "沒有產生Type C tester LOG files<br>請聯繫MTE!!" 0xFFFFFF -bg 0x882222
taskkill /IM Screen-diag.exe
Screen-diag.exe -nl -enter /SS 55 "沒有產生Type C tester LOG files<br>請聯繫MTE!!" 0xFFFFFF -bg 0x882222
taskkill /IM Screen-diag.exe
exit /b 252

