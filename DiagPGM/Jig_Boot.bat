cd %~dp0
call Jig_Init_FCT.bat
call ..\BSC\Initial.bat
NIControl-diags.exe -nl /sio 1.3 1
NIControl-diags.exe -nl /sio 1.1 1
NIControl-diags.exe -nl /sio 1.4 1
NIControl-diags.exe -nl /sio 1.6 1
Chopper-diag.exe /delay 2000 2>nul
NIControl-diags.exe -nl /sio 1.6 0
NIControl-diags.exe -nl /sio 2.6 0
Chopper-diag.exe /delay 19000 2>nul
:VCORE
Chopper-diag.exe /delay 1000 2>nul
NIControl-diags.exe -nl /gv 3 0.55 1.5
IF %ERRORLEVEL% NEQ 0 GOTO VCORE
ping-auto.exe -o /P 192.168.1.51