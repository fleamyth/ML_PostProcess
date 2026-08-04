@echo off
cd %~dp0
rem Tank Remote Test

:Audio_DMIC_L

del .\temp\DMIC_Audio_R_Test_Result.txt

rem Execute DMIC L LoopBack

LANRS-Diags.exe /E -ip 192.168.1.51 -f "E:\Diags\Jalama\Tools\_Audio_DMIC_R_mockup.cmd" -w -timeout 30 

rem Collect log 

call LANRS-Diags.exe /QD -ip 192.168.1.51 -rf "E:\Diags\Jalama\Tools\Temp" -to "." -w -timeout 30

rem Check Log 

timeout 2

if not exist .\temp\DMIC_Audio_R_Test_Result.txt exit /b 254

setlocal enabledelayedexpansion
if exist .\temp\DMIC_Audio_R.txt del .\temp\DMIC_Audio_R.txt
if exist .\temp\DMIC_Audio_R_DB.txt del .\temp\DMIC_Audio_R_DB.txt
if exist .\temp\DMIC_Audio_R_THD.txt del .\temp\DMIC_Audio_R_THD.txt
if exist .\temp\DMIC_Audio_R_Freq.txt del .\temp\DMIC_Audio_R_Freq.txt
find "Index AVG (Average)" .\temp\DMIC_Audio_R_Test_Result.txt > .\temp\DMIC_Audio_R.txt

for /f "skip=2 tokens=1-7 delims==," %%a in (.\temp\DMIC_Audio_R.txt) do (
	set DB=%%d
)

set DB=%DB: =%
echo !DB!>.\temp\DMIC_Audio_R_DB.txt

for /f "skip=2 tokens=1-7 delims==," %%a in (.\temp\DMIC_Audio_R.txt) do (
	set THD=%%f
)

set THD=%THD: =%
echo !THD!>.\temp\DMIC_Audio_R_THD.txt

for /f "skip=2 tokens=1-7 delims==," %%a in (.\temp\DMIC_Audio_R.txt) do (
	set Freq=%%b
)

set Freq=%Freq: =%
echo !Freq!>.\temp\DMIC_Audio_R_Freq.txt

endlocal


find "Passed Count : 0" .\temp\DMIC_Audio_R_Test_Result.txt
if %errorlevel% equ 0 set rtn=255& goto end
find "Failed Count : 0" .\temp\DMIC_Audio_R_Test_Result.txt
if %errorlevel% equ 0 set rtn=0& goto end
set rtn=255& goto end

:end
if defined rtn (
	exit /b %rtn% 
) else (
	exit /b 255
)