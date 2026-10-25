@echo off
cd /d "%~dp0"
Title ML_PostProcess_Online_Mode
SET SFISCONN=True
SET FIXCTL=True
call start.bat PostProcess
