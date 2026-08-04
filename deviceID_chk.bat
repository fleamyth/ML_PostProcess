@echo off
cd %~dp0

IF "%on_Drive%" EQU "" SET on_Drive=N:
:START
IF EXIST tester.ini DEL tester.ini
IF EXIST deviceID.txt DEL deviceID.txt
IF EXIST deviceID.ini DEL deviceID.ini
set file=%on_Drive%\Shawville_Device_ID.dat

IF NOT EXIST %file% DiagPGM\Screen-diag.exe -nl -enter /ss 50 "Error: 找不到對應的SeverList: [%file%]<br>==============<br>請聯繫工廠PE!!<br>==============<br>Press [Enter] to retry" 0xFFFFFF -bg 0xff8c00&exit /b 255

hostname>Tester.ini
set /p tester=<Tester.ini
ECHO.
ECHO Tester: [%tester%]
REM find the DeviceID from severlist
DiagPGM\PT-diags.exe -nl /find "%file%" "%tester%," >deviceID.txt
IF %ERRORLEVEL% EQU 0 GOTO Dup_Tester
DiagPGM\Screen-diag.exe -nl -enter /ss 50 "SeverList: [%file%] <br>Tester: [%tester%] <br>Error: 找不到對應的Device_ID<br>==============<br>請聯繫工廠PE!!<br>==============<br>Press [Enter] to retry" 0xFFFFFF -bg 0xff8c00
exit /b 255

:Dup_Tester
REM total numbers of TesterName = 1
ECHO.
ECHO Check Duplicate Tester: [%tester%]...
DiagPGM\PT-diags.exe -nl -line 1 /CLS deviceID.txt
IF %ERRORLEVEL% EQU 0 GOTO Get_DeviceID
type deviceID.txt
DiagPGM\Screen-diag.exe -nl -enter /ss 50 "SeverList: [%file%] <br>Tester: [%tester%] <br>Error: 找到重複的Tester Name<br>==============<br>請聯繫工廠PE!!<br>==============<br>Press [Enter] to retry" 0xFFFFFF -bg 0xff8c00
exit /b 255

:Get_DeviceID
ECHO.
ECHO.
ECHO Get DeviceID...
REM save the deviceID to deviceID.ini
DiagPGM\PT-diags.exe -nl -sl 1 -el 1 -start_comma 1 -end_comma 2 /Gstr "deviceID.txt" >deviceID.ini
REM make sure the DeviceID is 6 numbers of digit
ECHO Check DeviceID Length...
DiagPGM\PT-diags.exe -nl /FS deviceID.ini 6
IF %ERRORLEVEL% EQU 1 GOTO Dup_DeviceID
set /p deviceID=<deviceID.ini
DiagPGM\Screen-diag.exe -nl -enter /ss 50 "SeverList: [%file%] <br> DeviceID: [%deviceID%] <br>Error: 長度不為6碼, 格式錯誤<br>==============<br>請聯繫工廠PE!!<br>==============<br>Press [Enter] to retry" 0xFFFFFF -bg 0xff8c00
exit /b 255

:Dup_DeviceID
set /p deviceID=<deviceID.ini
ECHO.
ECHO Check duplicate DeviceID: [%deviceID%]
REM total numbers of DeviceID = 1
DiagPGM\PT-diags.exe /find "%file%" ",%deviceID%" -nl >deviceID.txt
DiagPGM\PT-diags.exe -nl -line 1 /CLS deviceID.txt
IF %ERRORLEVEL% EQU 0 GOTO END
type deviceID.txt
DiagPGM\Screen-diag.exe -nl -enter /ss 50 "SeverList: [%file%] <br> DeviceID: %deviceID%<br>Error: 找到重複的Device ID<br>==============<br>請聯繫工廠PE!!<br>==============<br>Press [Enter] to retry" 0xFFFFFF -bg 0xff8c00
exit /b 255

rem echo %deviceID%

:End
echo %deviceID%
EXIT /B 0