@echo off
cd %~dp0
powershell -command "get-physicaldisk |fl" >SSD_powershell_disk.log