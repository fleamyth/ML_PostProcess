
CD "%~dp0"

rem Transfer files to DUT to Update test item
LANRS-Diags.exe /sd -ip 192.168.1.51 -f ".\Update" -rto "E:\Diags\Jalama\Tools" -w -e 0
REM LANRS-Diags.exe /sd -ip 192.168.1.51 -f ".\Update\TypeCtester0" -rto "E:\Diags\Jalama\Tools" -w -e 0
REM LANRS-Diags.exe /sd -ip 192.168.1.51 -f ".\Update\TypeCtester1" -rto "E:\Diags\Jalama\Tools" -w -e 0
REM LANRS-Diags.exe /sd -ip 192.168.1.51 -f ".\Update\_Audio_DMIC_L_mockup.bat" -rto "E:\Diags\Jalama\Tools" -w -e 0
REM LANRS-Diags.exe /sd -ip 192.168.1.51 -f ".\Update\_Audio_DMIC_R_mockup.bat" -rto "E:\Diags\Jalama\Tools" -w -e 0
REM LANRS-Diags.exe /sd -ip 192.168.1.51 -f ".\Update\Update.bat" -rto "E:\Diags\Jalama\Tools\Update" -w -e 0
REM LANRS-Diags.exe /sd -ip 192.168.1.51 -f ".\Temp" -rto "C:\Tools" -w -e 0
LANRS-Diags.exe /E -ip 192.168.1.51 -f "E:\Diags\Jalama\Tools\Update\Update.bat"

exit /b 0