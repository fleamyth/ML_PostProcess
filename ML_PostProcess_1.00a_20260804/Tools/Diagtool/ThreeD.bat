@echo off 
cd %~dp0

set min=10
set max=100
set sec=4

IF "%1" NEQ  "" SET  min=%1
IF "%2" NEQ  "" SET  max=%2
IF "%3" NEQ  "" SET  sec=%3

IF EXIST ThreeD.log DEL ThreeD.log
Video-diags.exe -d %sec% -sf ThreeD.log -fmin %min% -fmax %max% /3D
set error=%errorlevel%
IF EXIST ThreeD.log TYPE ThreeD.log

EXIT /b %error%
