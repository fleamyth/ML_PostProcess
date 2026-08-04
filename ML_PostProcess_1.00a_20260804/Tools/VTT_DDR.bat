@echo off
cd %~dp0..
SET Log=VTT_DDR.log
IF EXIST %Log% DEL %Log%

Tools\NIControl-diags.exe -nl /gv 13 -1000 1000 > VTT_DDR_G.log
IF %ERRORLEVEL% EQU 255 EXIT /B 255

Tools\PT-diags.exe -nl -minus 0.02 /gv VTT_DDR_G.log "Voltage: " %1 %2 > %Log%
EXIT /B %ERRORLEVEL%
