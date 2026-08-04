cd %~dp0
SET Ver=1.04c
SET DateVer=20150518

SET FOLDER=Chariot_FCT_%Ver%_%DateVer%
..\%FOLDER%\Tools\PwrStateCtrl-diag.exe -nl /poweroff
IF %ERRORLEVEL% NEQ 0 pause
:Vcore
Chopper-diag.exe /delay 100 2> nul
ECHO.
ECHO Check Vcore off
NIControl-diags.exe -nl /sio 2.6 0
NIControl-diags.exe -nl /gv 3 -1 1.5
IF %ERRORLEVEL% NEQ 0 GOTO Vcore

:V1P2V_DUAL
Chopper-diag.exe /delay 100 2> nul
ECHO.
ECHO Check +1P2V_DUAL off
NIControl-diags.exe -nl /gv 16 -1 1
IF %ERRORLEVEL% NEQ 0 GOTO V1P2V_DUAL

:pass
call Jig_END_FCT.bat