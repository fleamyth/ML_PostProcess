@echo off
cd %~dp0
set /a exitcode=255
set log=EEUPDATEW64e.log

:check_mac
if not exist LAN_MAC.dat exit /b 255
set /p MACN=<LAN_MAC.dat

:write
del %log%
echo LAN MAC address write--->>%log%
C:\DiagTool\LAN\EEUpdate\EEUPDATEW64e.exe /nic=1 /mac=%MACN% >>%log%
set /a exitcode=%errorlevel%
echo LAN Write return code: %exitcode% >>%log%
timeout /t 1 /nobreak

REM echo LAN device restart--->>%log%
REM devcon.exe /find pci* > lan_pci_all.log 
REM PT-diags.exe /find lan_pci_all.log "Intel(R) Ethernet" > LAN_PCI.log
REM PT-diags.exe /gstr LAN_PCI.log -sa 11 -ea 31 > lan_device.log
REM set /p lan_device=<lan_device.log

rem devcon.exe restart "%lan_device%" >>%log%
rem if %errorlevel% neq 0 set /a exitcode=%errorlevel%
rem echo LAN device restart return code:%exitcode%-->>%log%
rem timeout /t 1 /nobreak

shutdown /r

exit /b %exitcode%


