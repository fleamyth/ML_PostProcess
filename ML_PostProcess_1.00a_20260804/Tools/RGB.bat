@echo off
cd %~dp0..
set /p IP=<IP.dat
set tool_path=c:\DiagTool
SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat

SET TestItem=RGB
SET Log=RGB.log
SET log_path=%tool_path%\%log%
IF EXIST sn.dat IF "%SN%" EQU "" SET /p SN=<sn.dat
IF EXIST TSRID.dat IF "%TSRID%" EQU "" SET /p TSRID=<TSRID.dat

set /a EXITCODE=0

:random_set
set /a num=%random% %%6+1
echo %num%
if %num% equ 1 goto rgb
if %num% equ 2 goto rbg
if %num% equ 3 goto brg
if %num% equ 4 goto bgr
if %num% equ 5 goto grb
if %num% equ 6 goto gbr

:RGB
rem red
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg ff0000"
tools\btn-diag.exe /btns tools\btn_rgb.ini -time 180
if %errorlevel% equ 254 set /a EXITCODE=6
if %errorlevel% equ 255 set /a EXITCODE=255
if %errorlevel% neq 1 set /a EXITCODE=3

timeout /t 1 /nobreak
if %EXITCODE% neq 0 tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe" & exit /b %EXITCODE%

rem green
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg 00ff00"
tools\btn-diag.exe /btns tools\btn_rgb.ini -time 180
if %errorlevel% equ 254 set /a EXITCODE=6
if %errorlevel% equ 255 set /a EXITCODE=255
if %errorlevel% neq 2 set /a EXITCODE=4

timeout /t 1 /nobreak
if %EXITCODE% neq 0 tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe" & exit /b %EXITCODE%

rem blue
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg 0000ff"
tools\btn-diag.exe /btns tools\btn_rgb.ini -time 180
if %errorlevel% equ 254 set /a EXITCODE=6
if %errorlevel% equ 255 set /a EXITCODE=255
if %errorlevel% neq 3 set /a EXITCODE=5

timeout /t 1 /nobreak
if %EXITCODE% neq 0 tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe" & exit /b %EXITCODE%

tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe" & exit /b %EXITCODE%

:RBG
rem red
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg ff0000"
tools\btn-diag.exe /btns tools\btn_rgb.ini -time 180
if %errorlevel% equ 254 set /a EXITCODE=6
if %errorlevel% equ 255 set /a EXITCODE=255
if %errorlevel% neq 1 set /a EXITCODE=3

timeout /t 1 /nobreak
if %EXITCODE% neq 0 tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe" & exit /b %EXITCODE%

rem blue
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg 0000ff"
tools\btn-diag.exe /btns tools\btn_rgb.ini -time 180
if %errorlevel% equ 254 set /a EXITCODE=6
if %errorlevel% equ 255 set /a EXITCODE=255
if %errorlevel% neq 3 set /a EXITCODE=5

timeout /t 1 /nobreak
if %EXITCODE% neq 0 tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe" & exit /b %EXITCODE%

rem green
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg 00ff00"
tools\btn-diag.exe /btns tools\btn_rgb.ini -time 180
if %errorlevel% equ 254 set /a EXITCODE=6
if %errorlevel% equ 255 set /a EXITCODE=255
if %errorlevel% neq 2 set /a EXITCODE=4

timeout /t 1 /nobreak
if %EXITCODE% neq 0 tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe" & exit /b %EXITCODE%

tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe" & exit /b %EXITCODE%

:BRG
rem blue
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg 0000ff"
tools\btn-diag.exe /btns tools\btn_rgb.ini -time 180
if %errorlevel% equ 254 set /a EXITCODE=6
if %errorlevel% equ 255 set /a EXITCODE=255
if %errorlevel% neq 3 set /a EXITCODE=5

timeout /t 1 /nobreak
if %EXITCODE% neq 0 tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe" & exit /b %EXITCODE%
rem green
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg 00ff00"
tools\btn-diag.exe /btns tools\btn_rgb.ini -time 180
if %errorlevel% equ 254 set /a EXITCODE=6
if %errorlevel% equ 255 set /a EXITCODE=255
if %errorlevel% neq 2 set /a EXITCODE=4

timeout /t 1 /nobreak
if %EXITCODE% neq 0 tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe" & exit /b %EXITCODE%
rem red
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg ff0000"
tools\btn-diag.exe /btns tools\btn_rgb.ini -time 180
if %errorlevel% equ 254 set /a EXITCODE=6
if %errorlevel% equ 255 set /a EXITCODE=255
if %errorlevel% neq 1 set /a EXITCODE=3

timeout /t 1 /nobreak
if %EXITCODE% neq 0 tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe" & exit /b %EXITCODE%
tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe" & exit /b %EXITCODE%

:BGR
rem blue
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg 0000ff"
tools\btn-diag.exe /btns tools\btn_rgb.ini -time 180
if %errorlevel% equ 254 set /a EXITCODE=6
if %errorlevel% equ 255 set /a EXITCODE=255
if %errorlevel% neq 3 set /a EXITCODE=5

timeout /t 1 /nobreak
if %EXITCODE% neq 0 tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe" & exit /b %EXITCODE%
rem red
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg ff0000"
tools\btn-diag.exe /btns tools\btn_rgb.ini -time 180
if %errorlevel% equ 254 set /a EXITCODE=6
if %errorlevel% equ 255 set /a EXITCODE=255
if %errorlevel% neq 1 set /a EXITCODE=3

timeout /t 1 /nobreak
if %EXITCODE% neq 0 tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe" & exit /b %EXITCODE%
rem green
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg 00ff00"
tools\btn-diag.exe /btns tools\btn_rgb.ini -time 180
if %errorlevel% equ 254 set /a EXITCODE=6
if %errorlevel% equ 255 set /a EXITCODE=255
if %errorlevel% neq 2 set /a EXITCODE=4

timeout /t 1 /nobreak
if %EXITCODE% neq 0 tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe" & exit /b %EXITCODE%
tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe" & exit /b %EXITCODE%

:GRB
rem green
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg 00ff00"
tools\btn-diag.exe /btns tools\btn_rgb.ini -time 180
if %errorlevel% equ 254 set /a EXITCODE=6
if %errorlevel% equ 255 set /a EXITCODE=255
if %errorlevel% neq 2 set /a EXITCODE=4

timeout /t 1 /nobreak
if %EXITCODE% neq 0 tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe" & exit /b %EXITCODE%
rem red
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg ff0000"
tools\btn-diag.exe /btns tools\btn_rgb.ini -time 180
if %errorlevel% equ 254 set /a EXITCODE=6
if %errorlevel% equ 255 set /a EXITCODE=255
if %errorlevel% neq 1 set /a EXITCODE=3

timeout /t 1 /nobreak
if %EXITCODE% neq 0 tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe" & exit /b %EXITCODE%
rem blue
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg 0000ff"
tools\btn-diag.exe /btns tools\btn_rgb.ini -time 180
if %errorlevel% equ 254 set /a EXITCODE=6
if %errorlevel% equ 255 set /a EXITCODE=255
if %errorlevel% neq 3 set /a EXITCODE=5

timeout /t 1 /nobreak
if %EXITCODE% neq 0 tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe" & exit /b %EXITCODE%
tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe" & exit /b %EXITCODE%

:GBR
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg 00ff00"
tools\btn-diag.exe /btns tools\btn_rgb.ini -time 180
if %errorlevel% equ 254 set /a EXITCODE=6
if %errorlevel% equ 255 set /a EXITCODE=255
if %errorlevel% neq 2 set /a EXITCODE=4

timeout /t 1 /nobreak
if %EXITCODE% neq 0 tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe" & exit /b %EXITCODE%
rem blue
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg 0000ff"
tools\btn-diag.exe /btns tools\btn_rgb.ini -time 180
if %errorlevel% equ 254 set /a EXITCODE=6
if %errorlevel% equ 255 set /a EXITCODE=255
if %errorlevel% neq 3 set /a EXITCODE=5

timeout /t 1 /nobreak
if %EXITCODE% neq 0 tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe" & exit /b %EXITCODE%
rem red
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg ff0000"
tools\btn-diag.exe /btns tools\btn_rgb.ini -time 180
if %errorlevel% equ 254 set /a EXITCODE=6
if %errorlevel% equ 255 set /a EXITCODE=255
if %errorlevel% neq 1 set /a EXITCODE=3

timeout /t 1 /nobreak
if %EXITCODE% neq 0 tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe" & exit /b %EXITCODE%
tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe" & exit /b %EXITCODE% 