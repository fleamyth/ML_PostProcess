pushd "%~dp0"
echo Start > E:\PCBA.flg
rem del E:\Diags\Jalama\Tools\Update\LanRS.bat
rem rmdir /S /Q "E:\Diags\Jalama\Tools\Update\DriverRemove"
del C:\Data\BiFrost\Logs\BiFrostModuleButton\*.txt
del C:\Data\BiFrost\Logs\BiFrostModuleRadio\*.txt
del C:\Data\BiFrost\Logs\BiFrostModuleSensor\*.txt
del C:\Data\BiFrost\Logs\BiFrostModuleSystem\*.txt
del C:\Data\BiFrost\Logs\BiFrostModulePower\*.txt
xcopy * ..\ /y /E
TASKKILL /FI "WINDOWTITLE eq Administrator:  Battery_record"

rmdir /S /Q "E:\Diags\Jalama\Tools\Temp"
mkdir "E:\Diags\Jalama\Tools\Temp"
taskkill /f /im "Chopper-diag.exe"
REM copy E:\Battery_record_in_DUt.log E:\Diags\Jalama\Tools\Temp\Battery_record_in_DUt.log
REM echo CURRENT DUT_TIME IS %DATE% %TIME% >E:\Diags\Jalama\Tools\Temp\DUT_TIME_record.log
REM dir C:\Windows\System32\mfc140d.dll >..\Temp\copyAudioDLL_log.txt
REM dir C:\Windows\System32\ucrtbased.dll >> ..\Temp\copyAudioDLL_log.txt
REM dir C:\Windows\System32\vcruntime140_1d.dll >> ..\Temp\copyAudioDLL_log.txt
REM dir C:\Windows\System32\vcruntime140d.dll >> ..\Temp\copyAudioDLL_log.txt

REM IF NOT EXIST C:\Windows\System32\mfc140d.dll copy /y ..\DLL\mfc140d.dll C:\Windows\System32 >> ..\Temp\copyAudioDLL_log.txt
REM IF NOT EXIST C:\Windows\System32\ucrtbased.dll copy /y ..\DLL\ucrtbased.dll C:\Windows\System32 >> ..\Temp\copyAudioDLL_log.txt
REM IF NOT EXIST C:\Windows\System32\vcruntime140_1d.dll copy /y ..\DLL\vcruntime140_1d.dll C:\Windows\System32 >> ..\Temp\copyAudioDLL_log.txt
REM IF NOT EXIST C:\Windows\System32\vcruntime140d.dll copy /y ..\DLL\vcruntime140d.dll C:\Windows\System32 >> ..\Temp\copyAudioDLL_log.txt
REM mkdir "C:\tools\Sensors\SurfaceSensors"
REM IF NOT EXIST C:\tools\Sensors\SurfaceSensors\SurfaceSensors.exe xcopy ..\SurfaceSensors\* C:\tools\Sensors\SurfaceSensors\ /y /E > ..\Temp\copySurfaceSensors_log.txt
exit /b 0