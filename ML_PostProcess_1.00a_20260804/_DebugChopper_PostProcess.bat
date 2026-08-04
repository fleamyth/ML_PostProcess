@ECHO ON
del *.log
del *.dat
DEL *.TXT
CD %~dp0..
COPY DiagPGM\OP.dat OP.dat 
COPY DiagPGM\SN.dat SN.dat 

CALL CONFIG.BAT SmokeTest offline
move *.dat %~dp0
CD %~dp0

IF NOT EXIST SN.dat ECHO THISISATESTSNUMB>SN.dat
IF NOT EXIST OP.dat ECHO S12345678>OP.dat

SET CFG_NAME=config_Deb.xml
Chopper-diag.exe -c -CGV -opf op.dat -SNF SN.dat -sip -TSRID -lock -RL -f %CFG_NAME% -e -rs -c2e -adr -SNP "^[0-9,A-Z]{12}$" /r
IF %ERRORLEVEL% EQU 250 pause & exit /b
IF %ERRORLEVEL% EQU 251 pause & exit /b
IF %ERRORLEVEL% EQU 252 pause & exit /b
IF %ERRORLEVEL% EQU 253 pause & exit /b
IF %ERRORLEVEL% EQU 254 pause & exit /b