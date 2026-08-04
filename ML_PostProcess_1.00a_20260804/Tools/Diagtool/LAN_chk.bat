@echo on
cd %~dp0

goto %1

:Connection
Lan-diags.exe /C -d "Realtek USB GbE Family Controller"
if %errorlevel% == 0 goto Pass

Lan-diags.exe /C -d "Surface Ethernet Adapter"
if %errorlevel% == 0 goto Pass
goto Fail


:Speed
Lan-diags.exe /S 1000 -d "Realtek USB GbE Family Controller"
if %errorlevel% == 0 goto Pass

Lan-diags.exe /S 1000 -d "Surface Ethernet Adapter"
if %errorlevel% == 0 goto Pass
goto Fail


:Pass
exit /b 0

:Fail
exit /b 255