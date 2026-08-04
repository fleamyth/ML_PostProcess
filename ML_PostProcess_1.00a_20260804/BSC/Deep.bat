@ECHO OFF
cd %~dp0..
ECHO S5 current control
Tools\NIControl-diags.exe  -nl /sio 2.4 0

ECHO Deep current control
Tools\NIControl-diags.exe  -nl /sio 2.5 1

ECHO Battery_charge_EN
Tools\NIControl-diags.exe  -nl /sio 2.3 0

:Start
ECHO GPIO1_IO_A = 0
Tools\NIControl-diags.exe  -nl /sio 0.0 0

ECHO GPIO2_IO_A = 1
Tools\NIControl-diags.exe  -nl /sio 0.1 1

ECHO GPIO3_IO_A = 1
Tools\NIControl-diags.exe  -nl /sio 0.2 1

ECHO +PreCharge_EN = 0
Tools\NIControl-diags.exe  -nl /sio 0.5 0

ECHO +CC_MODE_EN= 0  +BatteryLow_EN = 0
Tools\NIControl-diags.exe  -nl /sio 0.4 0

ECHO +BAT_MODE_EN= 1
Tools\NIControl-diags.exe  -nl /sio 0.6 1

ECHO +CV_MODE_EN= 0
Tools\NIControl-diags.exe  -nl /sio 0.7 0

ECHO Delay 100ms
Chopper-diag.exe /delay 100 2>nul


ECHO +BAT_EN#_A = 0
Tools\NIControl-diags.exe  -nl /sio 1.0 1

ECHO +BAT_PWRGD =1
Tools\NIControl-diags.exe  -nl /Gio 1.2 1
IF %ERRORLEVEL% NEQ 0 GOTO START

ECHO BAT_DET_IO_A =1
Tools\NIControl-diags.exe  -nl /sio 0.3 1

ECHO AC_EN = 0
Tools\NIControl-diags.exe  -nl /sio 1.1 0

ECHO test time!!!! remember to change back initial