@echo off
cd %~dp0
REM delete existing bin file
Del *.bin
Del *.p7s
REM Getting UEFI blob
GetSerialNumberForUEFIUnlock.exe