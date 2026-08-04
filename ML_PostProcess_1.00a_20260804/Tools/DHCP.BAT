:START
IF NOT EXIST "C:\Program Files\DHCP Server Service\DHCPServerService.exe" Screen-diag.exe -nl -enter /SS 55 "C:\Program Files\DHCP Server Service\DHCPServerService.exe Not Exist<br>檔案不存在, 請先放置後繼續" 0xFFFFFF -bg 0x882222 & GOTO START
"C:\Program Files\DHCP Server Service\DHCPServerService.exe" -S