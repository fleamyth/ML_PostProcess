@ECHO OFF
cd %~dp0..

:Start
ECHO S5 current control
Tools\NIControl-diags.exe -nl /sio 2.4 0

ECHO Deep current control
Tools\NIControl-diags.exe -nl /sio 2.5 0

ECHO Battery_charge_EN = 1
Tools\NIControl-diags.exe -nl /sio 2.3 1

ECHO 12V ON
Tools\NIControl-diags.exe -nl /sio 1.3 1

REM ECHO AC_EN = 0
REM Tools\NIControl-diags.exe -nl /sio 1.1 0

ECHO GPIO1_IO_A = 0
Tools\NIControl-diags.exe -nl /sio 0.0 0

ECHO GPIO2_IO_A = 1
Tools\NIControl-diags.exe -nl /sio 0.1 1

ECHO GPIO3_IO_A = 0
Tools\NIControl-diags.exe -nl /sio 0.2 0

ECHO +PreCharge_EN = 0
Tools\NIControl-diags.exe -nl /sio 0.5 0

ECHO +CC_MODE_EN= 1 +BatteryLow_EN = 1
Tools\NIControl-diags.exe -nl /sio 0.4 1

ECHO +BAT_MODE_EN= 0
Tools\NIControl-diags.exe -nl /sio 0.6 0

ECHO +CV_MODE_EN= 0
Tools\NIControl-diags.exe -nl /sio 0.7 0

ECHO Delay 100ms
Chopper-diag.exe /delay 100 2>nul


ECHO +BAT_EN#_A = 0
Tools\NIControl-diags.exe -nl /sio 1.0 1

ECHO +BAT_PWRGD =1
Tools\NIControl-diags.exe -nl /Gio 1.2 1
IF %ERRORLEVEL% NEQ 0 GOTO START

ECHO BAT_DET_IO_A =1
Tools\NIControl-diags.exe -nl /sio 0.3 1

ECHO delay 100ms
Chopper-diag.exe /delay 100 2>nul

ECHO AC_EN = 1
Tools\NIControl-diags.exe -nl /sio 1.1 1

ECHO test time!!!! remember to change back initial