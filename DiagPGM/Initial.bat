@ECHO OFF
cd %~dp0

ECHO BAT_DET_IO_A =0
NIControl-diags.exe  -nl /sio 0.3 0

ECHO Delay 10ms
Chopper-diag.exe /delay 10 2>nul

ECHO +BAT_EN#_A = 1
NIControl-diags.exe  -nl /sio 1.0 0

ECHO +PreCharge_EN = 1
NIControl-diags.exe  -nl /sio 0.5 1

ECHO Delay 10ms
Chopper-diag.exe /delay 10 2>nul

ECHO +PreCharge_EN = 0
NIControl-diags.exe  -nl /sio 0.5 0


ECHO GPIO1_IO_A = 0
NIControl-diags.exe  -nl /sio 0.0 0

ECHO GPIO2_IO_A = 0
NIControl-diags.exe  -nl /sio 0.1 0

ECHO GPIO3_IO_A = 0
NIControl-diags.exe  -nl /sio 0.2 0

ECHO +PreCharge_EN = 0
NIControl-diags.exe  -nl /sio 0.5 0

ECHO +CC_MODE_EN= 0  +BatteryLow_EN = 0
NIControl-diags.exe  -nl /sio 0.4 0

ECHO +BAT_MODE_EN= 0
NIControl-diags.exe  -nl /sio 0.6 0

ECHO +CV_MODE_EN= 0
NIControl-diags.exe  -nl /sio 0.7 0


ECHO S5 current control
NIControl-diags.exe  -nl /sio 2.4 0

ECHO Deep current control
NIControl-diags.exe  -nl /sio 2.5 0

ECHO Battery_charge_EN = 1
NIControl-diags.exe  -nl /sio 2.3 1