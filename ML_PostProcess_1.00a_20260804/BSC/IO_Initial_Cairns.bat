@ECHO OFF
cd %~dp0..

SET PORT=GPIO_0
ECHO Initialing %PORT% ...
Tools\NIControl-diags.exe -nl /sio 0 00
IF %ERRORLEVEL% NEQ 0 GOTO FAIL

SET PORT=GPIO_1
ECHO Initialing %PORT% ...
Tools\NIControl-diags.exe -nl /sio 1 00
IF %ERRORLEVEL% NEQ 0 GOTO FAIL

goto single

SET PORT=GPIO_2
ECHO Initialing %PORT% ...
Tools\NIControl-diags.exe -nl /sio 2 00
IF %ERRORLEVEL% NEQ 0 GOTO FAIL

:FAIL
Tools\Screen-diag.exe -nl -enter /SS 55 "%PORT% - NI Device access error:  %ERRORLEVEL% <br>請檢查NI卡後重新測試!" 0xFFFFFF -bg 0x882222 
EXIT /B 255

:single

rem Tools\NIControl-diags.exe -nl /sio 0.0 1

rem Tools\NIControl-diags.exe -nl /sio 0.0 0

rem Tools\NIControl-diags.exe -nl /sio 0.1 0

rem Tools\NIControl-diags.exe -nl /sio 0.2 0

rem Tools\NIControl-diags.exe -nl /sio 0.3 0

rem Tools\NIControl-diags.exe -nl /sio 0.4 0

Tools\NIControl-diags.exe -nl /sio 0.5 0

Tools\NIControl-diags.exe -nl /sio 0.6 0

rem Tools\NIControl-diags.exe -nl /sio 0.7 0

rem Tools\NIControl-diags.exe -nl /sio 0.8 0

rem Tools\NIControl-diags.exe -nl /sio 0.10 0

rem Tools\NIControl-diags.exe -nl /sio 0.9 0

rem Tools\NIControl-diags.exe -nl /sio 0.11 0

rem Tools\NIControl-diags.exe -nl /sio 0.12 0

rem Tools\NIControl-diags.exe -nl /sio 0.13 0

rem Tools\NIControl-diags.exe -nl /sio 0.14 0

Tools\NIControl-diags.exe -nl /sio 0.16 1


rem Tools\NIControl-diags.exe -nl /sio 1.0 0

rem Tools\NIControl-diags.exe -nl /sio 1.1 1

rem Tools\NIControl-diags.exe -nl /sio 1.2 0


Tools\NIControl-diags.exe -nl /sv 0 0

Tools\NIControl-diags.exe -nl /sv 1 0

