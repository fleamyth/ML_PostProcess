@ECHO ON
cd %~dp0
SET Retry=10
:WaitStart
ECHO Init_Disable_signal_for_Dut_CPU_FAN
NIControl-diags.exe -dev dev2 -nl /sio 1.2 1

ECHO Init_Disable_signal_for_Dut_GPU_FAN
NIControl-diags.exe -dev dev2 -nl /sio 2.2 1

ECHO Init_Disable_signal_for_Fixture_FAN
NIControl-diags.exe -dev dev2 -nl /sio 2.1 1

echo PSU_12VB_CTL
NIControl-diags.exe -nl /sio 0.10 0
timeout /t 1 /nobreak

echo PSU_12VA_CTL
NIControl-diags.exe -nl /sio 0.9 0
timeout /t 1 /nobreak

ECHO Fixture_En_Disengaging_L (up cylinder)
NIControl-diags.exe -dev dev2 -nl /sio 1.0 0

Chopper-diag.exe /delay 800 2>nul
SET gio=
SET gioCount=0
:DET_UP
IF "%gioCount%" EQU "%Retry%" GOTO SensorFail
SET /a gioCount+=1
IF "%gio%" NEQ "" Chopper-diag.exe /delay 100 2>nul
ECHO.
ECHO %gioCount%.Check Engaging_Sensor_Output (up cylinder)
NIControl-diags.exe -dev dev2 -nl /Gio 2.3 1
IF %ERRORLEVEL% NEQ 0 SET gio=/Gio 2.3 1& GOTO DET_UP

REM FCT NO NEED UNLOCK
REM ECHO Top_Lock_Dut_Power_Ctrl_L (unlock cylinder)
REM NIControl-diags.exe -dev dev2 -nl /sio 1.2 0

Chopper-diag.exe /delay 500 2>nul
REM FCT NO NEED UNLOCK
REM SET gio=
REM SET gioCount=0
REM :DET_Unlock
REM IF "%gioCount%" EQU "%Retry%" GOTO SensorFail
REM SET /a gioCount+=1
REM IF "%gio%" NEQ "" Chopper-diag.exe /delay 100 2>nul
REM ECHO.
REM ECHO %gioCount%.Check Cover_Lock_Sensor_Output(unlock cylinder)
REM NIControl-diags.exe -dev dev2 -nl /Gio 2.4 1
REM IF %ERRORLEVEL% NEQ 0 SET gio=/Gio 1.1 1& GOTO DET_Unlock

ECHO Top_cover_open_L (open cylinder)
NIControl-diags.exe -dev dev2 -nl /sio 1.1 1

Chopper-diag.exe /delay 800 2>nul
SET gio=
SET gioCount=0
:DET_OPEN
IF "%gioCount%" EQU "%Retry%" GOTO SensorFail
SET /a gioCount+=1
IF "%gio%" NEQ "" Chopper-diag.exe /delay 100 2>nul
ECHO.
ECHO %gioCount%.Check Top_Cover_Close_Sensor_Output(open cylinder)
NIControl-diags.exe -dev dev2 -nl /Gio 2.6 1
IF %ERRORLEVEL% NEQ 0 SET gio=/Gio 2.6 1& GOTO DET_OPEN

Chopper-diag.exe /delay 3000 2>nul

ECHO Top_cover_open_L (reset open cylinder)
NIControl-diags.exe -dev dev2 -nl /sio 1.1 0

EXIT /B 0

:SensorFail
IF "%GIO%" EQU "/Gio 2.3 1" Screen-diag.exe -nl -enter /ss 50 "Detect cover sensor failed (%GIO%)<br> <br> Please make sure the cover is opened <br> 治具狀態無法開啟, 請確認治具狀態" 0xFFFFFF -bg 0x882222
IF "%GIO%" EQU "/Gio 2.6 1" Screen-diag.exe -nl -enter /ss 50 "Detect up cylinder failed (%GIO%)<br> <br> Please make sure the fixture status for down <br> 治具無法上抬, 請確認治具狀態" 0xFFFFFF -bg 0x882222
REM Screen-diag.exe -nl -enter /ss 80 "Sensor Status Check Fail. <br> <br> %GIO%" 0xFFFFFF -bg 0x882222
ECHO Top_cover_open_L (reset open cylinder)
NIControl-diags.exe -dev dev2L -nl /sio 1.1 0
EXIT /B 255

