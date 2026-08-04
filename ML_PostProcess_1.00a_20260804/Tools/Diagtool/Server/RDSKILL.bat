@echo off
Delay-Diags /s 2 > null
lanrs-diags.exe -f 1.bat -w -e 0 -ip 192.168.1.10 /e
if %errorlevel%==0 goto killRDS
Delay-Diags /s 2 > null
lanrs-diags.exe -f 1.bat -w -e 0 -ip 192.168.1.10 /e
if %errorlevel%==0 goto killRDS
Delay-Diags /s 2 > null
lanrs-diags.exe -f 1.bat -w -e 0 -ip 192.168.1.10 /e
if %errorlevel%==0 goto killRDS
Delay-Diags /s 2 > null
lanrs-diags.exe -f 1.bat -w -e 0 -ip 192.168.1.10 /e
if %errorlevel%==0 goto killRDS
Delay-Diags /s 2 > null
lanrs-diags.exe -f 1.bat -w -e 0 -ip 192.168.1.10 /e
if %errorlevel%==0 goto killRDS
Delay-Diags /s 2 > null
lanrs-diags.exe -f 1.bat -w -e 0 -ip 192.168.1.10 /e
if %errorlevel%==0 goto killRDS
Delay-Diags /s 2 > null
lanrs-diags.exe -f 1.bat -w -e 0 -ip 192.168.1.10 /e
if %errorlevel%==0 goto killRDS
Delay-Diags /s 2 > null
lanrs-diags.exe -f 1.bat -w -e 0 -ip 192.168.1.10 /e
if %errorlevel%==0 goto killRDS
Delay-Diags /s 2 > null
lanrs-diags.exe -f 1.bat -w -e 0 -ip 192.168.1.10 /e
if %errorlevel%==0 goto killRDS
Delay-Diags /s 2 > null
lanrs-diags.exe -f 1.bat -w -e 0 -ip 192.168.1.10 /e
if %errorlevel%==0 goto killRDS
goto end

:killRDS
taskkill /im KoreDeviceServer.exe /F

:end
exit