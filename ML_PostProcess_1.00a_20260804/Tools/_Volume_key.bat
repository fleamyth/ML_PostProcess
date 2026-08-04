@ECHO ON
cd %~dp0

if "%1"=="Down" (

start Screen-diag.exe -nl /Show vd.jpg
REM NIControl-diags -nl /sio 2.0 1
REM timeout 1
REM NIControl-diags -nl /sio 2.0 0


REM NIControl-diags -nl /sio 2.0 1
REM timeout 1
REM NIControl-diags -nl /sio 2.0 0

REM NIControl-diags -nl /sio 2.0 1

REM NIControl-diags -nl /sio 2.0 0
REM timeout 1
REM NIControl-diags -nl /sio 2.0 1


)



if "%1"=="Up" (

start Screen-diag.exe -nl /Show vu.jpg
REM NIControl-diags -nl /sio 1.7 1
REM timeout 1
REM NIControl-diags -nl /sio 1.7 0

REM NIControl-diags -nl /sio 1.7 1
REM timeout 1
REM NIControl-diags -nl /sio 1.7 0

REM NIControl-diags -nl /sio 1.7 1
REM timeout 1
REM NIControl-diags -nl /sio 1.7 0

REM NIControl-diags -nl /sio 1.7 1
REM timeout 1
REM NIControl-diags -nl /sio 1.7 0


)
