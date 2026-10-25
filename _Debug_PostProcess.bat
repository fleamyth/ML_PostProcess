@echo off
cd /d "%~dp0"
Title ML_PreProcess_Debug_Mode
SET DebugXML=True
SET SFISCONN=False
SET FIXCTL=True
call START.bat PostProcess D
