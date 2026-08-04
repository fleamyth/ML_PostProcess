@ECHO OFF
cd %~dp0
IF EXIST stop.flg DEL stop.flg
SET Retry=10

echo PSU_12VB_CTL
NIControl-diags.exe -nl /sio 0.10 0
timeout /t 1 /nobreak

echo PSU_12VA_CTL
NIControl-diags.exe -nl /sio 0.9 0
timeout /t 1 /nobreak

ECHO Top_cover_open_L (reset open cylinder)
NIControl-diags.exe -dev FIXCTL -nl /sio 1.1 0

ECHO Init_Disable_signal_for_Dut_CPU_FAN
NIControl-diags.exe -dev dev2 -nl /sio 1.2 1

ECHO Init_Disable_signal_for_Dut_GPU_FAN
NIControl-diags.exe -dev dev2 -nl /sio 2.2 1

ECHO Init_Disable_signal_for_Fixture_FAN
NIControl-diags.exe -dev dev2 -nl /sio 2.1 1

ECHO Init_Enable_NI_OUTPUT_CONTROL
NIControl-diags.exe -dev dev2 -nl /sio 1.0 0
NIControl-diags.exe -dev dev2 -nl /sio 1.1 0
NIControl-diags.exe -dev dev2 -nl /sio 1.2 0
NIControl-diags.exe -dev dev2 -nl /sio 1.3 0

set /a start_count=0
START Screen-diag.exe -enter /ss 100 "Press [START]" 0xFFFFFF -bg 0x667FFF
:DET_START
set /a start_count=%start_count%+1
if %start_count% gtr 180 goto stop
REM STOP
REM NIControl-diags.exe -dev dev2 -nl /Gio 1.6 0 
REM IF %ERRORLEVEL% EQU 0 GOTO stop
REM Chopper-diag.exe /delay 500 2>nul
Chopper-diag.exe /delay 1000 2>nul
NIControl-diags.exe -dev dev2 -nl /Gio 2.6 0
IF %ERRORLEVEL% NEQ 0 goto DET_START
rem Start
REM ECHO Waiting Start ....
REM NIControl-diags.exe -dev dev2 -nl /Gio 1.7 0 
REM IF %ERRORLEVEL% NEQ 0 GOTO DET_START

taskkill /IM Screen-diag.exe

Chopper-diag.exe /delay 100 2>nul
SET gio=
SET gioCount=0
:DET_Cover
IF "%gioCount%" EQU "%Retry%" GOTO SensorFail
SET /a gioCount+=1
IF "%gio%" NEQ "" Chopper-diag.exe /delay 100 2>nul
ECHO.
ECHO %gioCount%.Check Top_Cover_Close_Sensor_Output (close cylinder)
NIControl-diags.exe -dev dev2 -nl /Gio 2.6 0
IF %ERRORLEVEL% NEQ 0 SET gio=/Gio 2.6 0& GOTO DET_Cover


Chopper-diag.exe /delay 100 2>nul
SET gio=
SET gioCount=0
:DET_AirP
IF "%gioCount%" EQU "%Retry%" GOTO SensorFail
SET /a gioCount+=1
IF "%gio%" NEQ "" Chopper-diag.exe /delay 100 2>nul
ECHO.
ECHO %gioCount%.Check Air_Pressure_Sensor_Output (close cylinder)
NIControl-diags.exe -dev dev2 -nl /Gio 2.5 0
IF %ERRORLEVEL% NEQ 0 SET gio=/Gio 2.5 0& GOTO DET_AirP

Chopper-diag.exe /delay 100 2>nul
SET gio=
SET gioCount=0
:DET_Sensor123
REM Check DUT EXIST
IF "%gioCount%" EQU "%Retry%" GOTO SensorFail
SET /a gioCount+=1
IF "%gio%" NEQ "" Chopper-diag.exe /delay 100 2>nul
ECHO.
ECHO %gioCount%.Check Pre_Sensor123_ON_KEY1_OUTPUT
NIControl-diags.exe -dev dev2 -nl /Gio 0.0 0
IF %ERRORLEVEL% NEQ 0 SET gio=/Gio 0.0 0& GOTO DET_Sensor123


echo FCT LOCK
ECHO Top_cover_open_L
NIControl-diags.exe -dev dev2 -nl /sio 1.1 0
Chopper-diag.exe /delay 500 2>nul

echo Fixture_En_disengaging_L
NIControl-diags.exe -dev dev2 -nl /sio 1.0 1
Chopper-diag.exe /delay 500 2>nul


SET gio=
SET gioCount=0
:DET_Down
IF "%gioCount%" EQU "%Retry%" GOTO SensorFail
SET /a gioCount+=1
IF "%gio%" NEQ "" Chopper-diag.exe /delay 100 2>nul
ECHO.
ECHO %gioCount%.Check Engaging_Sensor_Output(down cylinder)
NIControl-diags.exe -dev dev2 -nl /Gio 2.3 0
IF %ERRORLEVEL% NEQ 0 SET gio=/Gio 2.3 0& GOTO DET_Down

rem call AUTO_Scan.bat

:PowerOn
ECHO On_Disable_signal_for_Dut_CPU_FAN
NIControl-diags.exe -dev dev2 -nl /sio 1.2 1

ECHO on_Disable_signal_for_Dut_GPU_FAN
NIControl-diags.exe -dev dev2 -nl /sio 2.2 1

ECHO on_Disable_signal_for_Fixture_FAN
NIControl-diags.exe -dev dev2 -nl /sio 2.1 1

EXIT /B 0
 
:SensorFail
IF "%GIO%" EQU "/Gio 2.6 0" Screen-diag.exe -nl -enter /ss 50 "Detect cover sensor failed (%GIO%)<br> <br> Please make sure the cover is closed <br> 請確認上蓋關上後重新測試" 0xFFFFFF -bg 0x882222
IF "%GIO%" EQU "/Gio 2.5 0" Screen-diag.exe -nl -enter /ss 50 "Detect air pressure failed (%GIO%)<br> <br> Please make sure the air pressure is correct <br> 請確認氣壓後重新測試" 0xFFFFFF -bg 0x882222
IF "%GIO%" EQU "/Gio 0.0 0" Screen-diag.exe -nl -enter /ss 50 "Detect DUT exist failed (%GIO%)<br> <br> Please make sure the DUT’s location <br> 請確認待測板位置後重新測試" 0xFFFFFF -bg 0x882222
IF "%GIO%" EQU "/Gio 2.3 0" Screen-diag.exe -nl -enter /ss 50 "Detect down cylinder failed (%GIO%)<br> <br> Please make sure the fixture status for down <br> 請確認治具可下壓後重新測試" 0xFFFFFF -bg 0x882222
REM Screen-diag.exe -nl -enter /ss 80 "Sensor Status Check Fail. <br> <br> %GIO%" 0xFFFFFF -bg 0x882222
ECHO Top_cover_open_L (reset open cylinder)
NIControl-diags.exe -dev dev2 -nl /sio 2.4 0
EXIT /B 255

:Stop
taskkill /IM Screen-diag.exe
echo. > stop.flg
EXIT /B 255


