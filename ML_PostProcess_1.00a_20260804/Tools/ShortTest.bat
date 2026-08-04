@echo off
REM Rtest=Vtest*(RTB+Ron)/(Vsource-Vtest)
Rem Rtest=%1*(%2+3)/(%3-%1)
rem %3=0.21 %2=100 or 22
REM AI RTB Vscource MIN MAX
cd %~dp0..
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat
SET TestItem=Short_Test
SET Log=Short_Test.log


SET Ron=3
SET AI=%1
SET /a RTBon=%2+%Ron%
SET Vsource=%3
SET Short_MIN=%4
SET Short_MAX=%5
IF "%Short_MAX%" EQU "" ECHO %date%_%time% Parameter Error! >%Log%  & GOTO GDataError

IF EXIST Short_*.log DEL Short_*.log
Tools\NIControl-diags.exe -nl /gv %1 -1000 1000 > Short_Vtest.log
IF %ERRORLEVEL% EQU 255 EXIT /B 255
ECHO %date%_%time% >%Log%
TYPE Short_Vtest.log >>%Log%
Tools\PT-diags.exe -nl -mul -1 -plus %Vsource% /gv Short_Vtest.log "Voltage: " -1000 1000 > Short_Vst.log
IF %ERRORLEVEL% EQU 255 GOTO GDataError

REM RTB
SET /p Vst=<Short_Vst.log
ECHO Vsource-Vtest: %Vst% >>%Log%

Tools\PT-diags.exe -nl -mul %RTBon% -div %Vst% /gv Short_Vtest.log "Voltage: " %Short_MIN% %Short_MAX% > Short_Rtest.log
SET EXITCODE=%ERRORLEVEL%
SET /p Rtest=<Short_Rtest.log
Tools\PT-diags.exe -nl /gv Short_Rtest.log "" 0 1 > Rtest_tmp.log
if %errorlevel% EQU 1 set Rtest=0.068

ECHO Rtest: %Rtest% >>%Log%
TYPE %Log%
ECHO =================================
ECHO Rtest ERROR CODE = %EXITCODE%
IF %EXITCODE% EQU 2 EXIT /B 0
IF %EXITCODE% EQU 255 GOTO GDataError
EXIT /B %EXITCODE%

:GDataError
Tools\LogTransfer-auto.exe -nl /de -
call setdate.bat
SET DEST=%MISC%\%TestItem%\%datepath%\
IF NOT EXIST %DEST% MKDIR %DEST%
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat
TYPE %Log% >>  %DEST%\%SN%_%TSRID%_%TestItem%_Fail.log
EXIT /B 232