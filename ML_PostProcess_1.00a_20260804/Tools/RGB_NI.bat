@echo off
cd %~dp0..
set /a error=0
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
DEl RED.flg
DEL BLUE.flg
DEL GREEN.flg
DEL NODIS.flg
DEL Timeout.flg
rem red
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg ff0000"
rem start Tools\btn_RGB.bat
start tools\btn_rgb_str.bat
Chopper-diag.exe /delay 1000
rem if %errorlevel% equ 254 set /a error=6
rem if %errorlevel% equ 255 set /a error=255
rem if %errorlevel% neq 1 set /a error=3


:chk_rgb_R
tasklist>tsklist.txt
rem check R button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_rgb_R_end
rem check G button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.5 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_R_fail
rem check B button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.6 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_R_fail
rem check NO button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 1.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO dis_fail
rem IF exist btn_rgb.log set /p ERROR=<rgb.log&GOTO end
find /i "btn-diag.exe" tsklist.txt
if %errorlevel% == 0 GOTO chk_rgb_R
rem ===check pass/fail by mouse click===
IF EXIST RED.flg GOTO chk_rgb_R_end
IF EXIST GREEN.flg GOTO chk_R_fail
IF EXIST BLUE.flg GOTO chk_R_fail
IF EXIST NODIS.flg GOTO dis_fail
IF EXIST Timeout.flg set error=254
rem close btn-diag by OP
goto 1067
:chk_rgb_R_end
del tsklist.txt
rem ==check button end==

tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe"
timeout /t 1 /nobreak
if %error% neq 0 exit /b %error%

rem green
DEl RED.flg
DEL BLUE.flg
DEL GREEN.flg
DEL NODIS.flg
DEL Timeout.flg
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg 00ff00"
start tools\btn_rgb_str.bat
Chopper-diag.exe /delay 1000
rem if %errorlevel% equ 254 set /a error=6
rem if %errorlevel% equ 255 set /a error=255
rem if %errorlevel% neq 2 set /a error=4


:chk_rgb_G
tasklist>tsklist.txt
rem check G button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.5 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_rgb_G_end
rem check R button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_G_fail
rem check B button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.6 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_G_fail
rem check NO button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 1.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO dis_fail
rem IF exist btn_rgb.log set /p ERROR=<rgb.log&GOTO end
find /i "btn-diag.exe" tsklist.txt
if %errorlevel% == 0 GOTO chk_rgb_G
rem ===check pass/fail by mouse click===
IF EXIST RED.flg GOTO chk_G_fail
IF EXIST GREEN.flg GOTO chk_rgb_G_end
IF EXIST BLUE.flg GOTO chk_G_fail
IF EXIST NODIS.flg GOTO dis_fail
IF EXIST Timeout.flg set error=254
rem close btn-diag by OP
goto 1067
:chk_rgb_G_end
del tsklist.txt
rem ==check button end==

tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe"
timeout /t 1 /nobreak
if %error% neq 0 exit /b %error%

rem blue
DEl RED.flg
DEL BLUE.flg
DEL GREEN.flg
DEL NODIS.flg
DEL Timeout.flg
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg 0000ff"
start tools\btn_rgb_str.bat
Chopper-diag.exe /delay 1000
rem if %errorlevel% equ 254 set /a error=6
rem if %errorlevel% equ 255 set /a error=255
rem if %errorlevel% neq 3 set /a error=5


:chk_rgb_B
tasklist>tsklist.txt
rem check B button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.6 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_rgb_B_end
rem check R button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_B_fail
rem check G button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.5 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_B_fail
rem check NO button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 1.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO dis_fail
rem IF exist btn_rgb.log set /p ERROR=<rgb.log&GOTO end
find /i "btn-diag.exe" tsklist.txt
if %errorlevel% == 0 GOTO chk_rgb_B
rem ===check pass/fail by mouse click===
IF EXIST RED.flg GOTO chk_B_fail
IF EXIST GREEN.flg GOTO chk_B_fail
IF EXIST BLUE.flg GOTO chk_rgb_B_end
IF EXIST NODIS.flg GOTO dis_fail
IF EXIST Timeout.flg set error=254
rem close btn-diag by OP
goto 1067
:chk_rgb_B_end
del tsklist.txt
rem ==check button end==

tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe"
timeout /t 1 /nobreak
if %error% neq 0 exit /b %error%
exit /b %error%

:RBG
DEl RED.flg
DEL BLUE.flg
DEL GREEN.flg
DEL NODIS.flg
DEL Timeout.flg
rem red
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg ff0000"
start tools\btn_rgb_str.bat
Chopper-diag.exe /delay 1000
rem if %errorlevel% equ 254 set /a error=6
rem if %errorlevel% equ 255 set /a error=255
rem if %errorlevel% neq 1 set /a error=3


:chk_rbg_R
tasklist>tsklist.txt
rem check R button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_rbg_R_end
rem check G button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.6 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_R_fail
rem check B button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.5 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_R_fail
rem check NO button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 1.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO dis_fail
rem IF exist btn_rgb.log set /p ERROR=<rgb.log&GOTO end
find /i "btn-diag.exe" tsklist.txt
if %errorlevel% == 0 GOTO chk_rbg_R
rem ===check pass/fail by mouse click===
IF EXIST RED.flg GOTO chk_rbg_R_end
IF EXIST GREEN.flg GOTO chk_R_fail
IF EXIST BLUE.flg GOTO chk_R_fail
IF EXIST NODIS.flg GOTO dis_fail
IF EXIST Timeout.flg set error=254
rem close btn-diag by OP
goto 1067
:chk_rbg_R_end
del tsklist.txt
rem ==check button end==

tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe"
timeout /t 1 /nobreak
if %error% neq 0 exit /b %error%


rem blue
DEl RED.flg
DEL BLUE.flg
DEL GREEN.flg
DEL NODIS.flg
DEL Timeout.flg

tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg 0000ff"
start tools\btn_rgb_str.bat
Chopper-diag.exe /delay 1000
rem if %errorlevel% equ 254 set /a error=6
rem if %errorlevel% equ 255 set /a error=255
rem if %errorlevel% neq 3 set /a error=5

:chk_rbg_B
tasklist>tsklist.txt
rem check B button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.6 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_rbg_B_end
rem check R button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_B_fail
rem check G button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.5 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_B_fail
rem check NO button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 1.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO dis_fail
rem IF exist btn_rgb.log set /p ERROR=<rgb.log&GOTO end
find /i "btn-diag.exe" tsklist.txt
if %errorlevel% == 0 GOTO chk_rbg_B
rem ===check pass/fail by mouse click===
IF EXIST RED.flg GOTO chk_B_fail
IF EXIST GREEN.flg GOTO chk_B_fail
IF EXIST BLUE.flg GOTO chk_rbg_B_end
IF EXIST NODIS.flg GOTO dis_fail
IF EXIST Timeout.flg set error=254
rem close btn-diag by OP
goto 1067
:chk_rbg_B_end
del tsklist.txt
rem ==check button end==

tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe"
timeout /t 1 /nobreak
if %error% neq 0 exit /b %error%

rem green
DEl RED.flg
DEL BLUE.flg
DEL GREEN.flg
DEL NODIS.flg
DEL Timeout.flg
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg 00ff00"
start tools\btn_rgb_str.bat
Chopper-diag.exe /delay 1000
rem if %errorlevel% equ 254 set /a error=6
rem if %errorlevel% equ 255 set /a error=255
rem if %errorlevel% neq 2 set /a error=4


:chk_rbg_G
tasklist>tsklist.txt
rem check G button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.5 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_rbg_G_end
rem check R button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_G_fail
rem check B button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.6 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_G_fail
rem check NO button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 1.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO dis_fail
rem IF exist btn_rgb.log set /p ERROR=<rgb.log&GOTO end
find /i "btn-diag.exe" tsklist.txt
if %errorlevel% == 0 GOTO chk_rbg_G
rem ===check pass/fail by mouse click===
IF EXIST RED.flg GOTO chk_G_fail
IF EXIST GREEN.flg GOTO chk_rbg_G_end
IF EXIST BLUE.flg GOTO chk_G_fail
IF EXIST NODIS.flg GOTO dis_fail
IF EXIST Timeout.flg set error=254
rem close btn-diag by OP
goto 1067
:chk_rbg_G_end
del tsklist.txt
rem ==check button end==

tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe"
timeout /t 1 /nobreak
if %error% neq 0 exit /b %error%
exit /b %error%

:BGR
rem blue
DEl RED.flg
DEL BLUE.flg
DEL GREEN.flg
DEL NODIS.flg
DEL Timeout.flg
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg 0000ff"
start tools\btn_rgb_str.bat
Chopper-diag.exe /delay 1000
rem if %errorlevel% equ 254 set /a error=6
rem if %errorlevel% equ 255 set /a error=255
rem if %errorlevel% neq 3 set /a error=5


:chk_bgr_B
tasklist>tsklist.txt
rem check B button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.6 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_bgr_B_end
rem check R button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_B_fail
rem check G button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.5 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_B_fail
rem check NO button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 1.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO dis_fail
rem IF exist btn_rgb.log set /p ERROR=<rgb.log&GOTO end
find /i "btn-diag.exe" tsklist.txt
if %errorlevel% == 0 GOTO chk_bgr_B
rem ===check pass/fail by mouse click===
IF EXIST RED.flg GOTO chk_B_fail
IF EXIST GREEN.flg GOTO chk_B_fail
IF EXIST BLUE.flg GOTO GOTO chk_bgr_B_end
IF EXIST NODIS.flg GOTO dis_fail
IF EXIST Timeout.flg set error=254
rem close btn-diag by OP
goto 1067
:chk_bgr_B_end
del tsklist.txt
rem ==check button end==

tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe"
timeout /t 1 /nobreak
if %error% neq 0 exit /b %error%

rem green
DEl RED.flg
DEL BLUE.flg
DEL GREEN.flg
DEL NODIS.flg
DEL Timeout.flg
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg 00ff00"
start tools\btn_rgb_str.bat
Chopper-diag.exe /delay 1000
rem if %errorlevel% equ 254 set /a error=6
rem if %errorlevel% equ 255 set /a error=255
rem if %errorlevel% neq 2 set /a error=4


:chk_bgr_G
tasklist>tsklist.txt
rem check G button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.5 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_bgr_G_end
rem check R button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_G_fail
rem check B button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.6 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_G_fail
rem check NO button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 1.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO dis_fail
rem IF exist btn_rgb.log set /p ERROR=<rgb.log&GOTO end
find /i "btn-diag.exe" tsklist.txt
if %errorlevel% == 0 GOTO chk_bgr_G
rem ===check pass/fail by mouse click===
IF EXIST RED.flg GOTO chk_G_fail
IF EXIST GREEN.flg GOTO chk_bgr_G_end
IF EXIST BLUE.flg GOTO chk_G_fail
IF EXIST NODIS.flg GOTO dis_fail
IF EXIST Timeout.flg set error=254
rem close btn-diag by OP
goto 1067
:chk_bgr_G_end
del tsklist.txt
rem ==check button end==

tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe"
timeout /t 1 /nobreak
if %error% neq 0 exit /b %error%

rem red
DEl RED.flg
DEL BLUE.flg
DEL GREEN.flg
DEL NODIS.flg
DEL Timeout.flg
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg ff0000"
start tools\btn_rgb_str.bat
Chopper-diag.exe /delay 1000
rem if %errorlevel% equ 254 set /a error=6
rem if %errorlevel% equ 255 set /a error=255
rem if %errorlevel% neq 1 set /a error=3


:chk_bgr_R
tasklist>tsklist.txt
rem check R button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_bgr_R_end
rem check G button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.5 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_R_fail
rem check B button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.6 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_R_fail
rem check NO button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 1.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO dis_fail
rem IF exist btn_rgb.log set /p ERROR=<rgb.log&GOTO end
find /i "btn-diag.exe" tsklist.txt
if %errorlevel% == 0 GOTO chk_bgr_R
rem ===check pass/fail by mouse click===
IF EXIST RED.flg GOTO chk_bgr_R_end
IF EXIST GREEN.flg GOTO chk_R_fail
IF EXIST BLUE.flg GOTO chk_R_fail
IF EXIST NODIS.flg GOTO dis_fail
IF EXIST Timeout.flg set error=254
rem close btn-diag by OP
goto 1067
:chk_bgr_R_end
del tsklist.txt
rem ==check button end==

tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe"
timeout /t 1 /nobreak
if %error% neq 0 exit /b %error%
exit /b %error%

:BRG
rem blue
DEl RED.flg
DEL BLUE.flg
DEL GREEN.flg
DEL NODIS.flg
DEL Timeout.flg
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg 0000ff"
start tools\btn_rgb_str.bat
Chopper-diag.exe /delay 1000
rem if %errorlevel% equ 254 set /a error=6
rem if %errorlevel% equ 255 set /a error=255
rem if %errorlevel% neq 3 set /a error=5


:chk_brg_B
tasklist>tsklist.txt
rem check B button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.6 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_brg_B_end
rem check R button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_B_fail
rem check G button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.5 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_B_fail
rem check NO button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 1.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO dis_fail
rem IF exist btn_rgb.log set /p ERROR=<rgb.log&GOTO end
find /i "btn-diag.exe" tsklist.txt
if %errorlevel% == 0 GOTO chk_brg_B
rem ===check pass/fail by mouse click===
IF EXIST RED.flg GOTO chk_B_fail
IF EXIST GREEN.flg GOTO chk_B_fail
IF EXIST BLUE.flg GOTO chk_brg_B_end
IF EXIST NODIS.flg GOTO dis_fail
IF EXIST Timeout.flg set error=254
rem close btn-diag by OP
goto 1067
:chk_brg_B_end
del tsklist.txt
rem ==check button end==

tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe"
timeout /t 1 /nobreak
if %error% neq 0 exit /b %error%

rem red
DEl RED.flg
DEL BLUE.flg
DEL GREEN.flg
DEL NODIS.flg
DEL Timeout.flg
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg ff0000"
start tools\btn_rgb_str.bat
Chopper-diag.exe /delay 1000
rem if %errorlevel% equ 254 set /a error=6
rem if %errorlevel% equ 255 set /a error=255
rem if %errorlevel% neq 1 set /a error=3


:chk_brg_R
tasklist>tsklist.txt
rem check R button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_brg_R_end
rem check G button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.5 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_R_fail
rem check B button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.6 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_R_fail
rem check NO button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 1.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO dis_fail
rem IF exist btn_rgb.log set /p ERROR=<rgb.log&GOTO end
find /i "btn-diag.exe" tsklist.txt
if %errorlevel% == 0 GOTO chk_brg_R
rem ===check pass/fail by mouse click===
IF EXIST RED.flg GOTO chk_brg_R_end
IF EXIST GREEN.flg GOTO chk_R_fail
IF EXIST BLUE.flg GOTO chk_R_fail
IF EXIST NODIS.flg GOTO dis_fail
IF EXIST Timeout.flg set error=254
rem close btn-diag by OP
goto 1067
:chk_brg_R_end
del tsklist.txt
rem ==check button end==

tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe"
timeout /t 1 /nobreak
if %error% neq 0 exit /b %error%

rem green
DEl RED.flg
DEL BLUE.flg
DEL GREEN.flg
DEL NODIS.flg
DEL Timeout.flg
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg 00ff00"
start tools\btn_rgb_str.bat
Chopper-diag.exe /delay 1000
rem if %errorlevel% equ 254 set /a error=6
rem if %errorlevel% equ 255 set /a error=255
rem if %errorlevel% neq 2 set /a error=4


:chk_brg_G
tasklist>tsklist.txt
rem check G button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.5 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_brg_G_end
rem check R button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_G_fail
rem check B button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.6 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_G_fail
rem check NO button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 1.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO dis_fail
rem IF exist btn_rgb.log set /p ERROR=<rgb.log&GOTO end
find /i "btn-diag.exe" tsklist.txt
if %errorlevel% == 0 GOTO chk_brg_G
rem ===check pass/fail by mouse click===
IF EXIST RED.flg GOTO chk_G_fail
IF EXIST GREEN.flg GOTO chk_brg_G_end
IF EXIST BLUE.flg GOTO chk_G_fail
IF EXIST NODIS.flg GOTO dis_fail
IF EXIST Timeout.flg set error=254
rem close btn-diag by OP
goto 1067
:chk_brg_G_end
del tsklist.txt
rem ==check button end==

tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe"
timeout /t 1 /nobreak
if %error% neq 0 exit /b %error%
exit /b %error%

:GRB
rem green
DEl RED.flg
DEL BLUE.flg
DEL GREEN.flg
DEL NODIS.flg
DEL Timeout.flg
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg 00ff00"
start tools\btn_rgb_str.bat
Chopper-diag.exe /delay 1000
rem if %errorlevel% equ 254 set /a error=6
rem if %errorlevel% equ 255 set /a error=255
rem if %errorlevel% neq 2 set /a error=4


:chk_grb_G
tasklist>tsklist.txt
rem check G button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.5 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_grb_G_end
rem check R button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_G_fail
rem check B button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.6 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_G_fail
rem check NO button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 1.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO dis_fail
rem IF exist btn_rgb.log set /p ERROR=<rgb.log&GOTO end
find /i "btn-diag.exe" tsklist.txt
if %errorlevel% == 0 GOTO chk_grb_G
rem ===check pass/fail by mouse click===
IF EXIST RED.flg GOTO chk_G_fail
IF EXIST GREEN.flg GOTO chk_grb_G_end
IF EXIST BLUE.flg GOTO chk_G_fail
IF EXIST NODIS.flg GOTO dis_fail
IF EXIST Timeout.flg set error=254
rem close btn-diag by OP
goto 1067
:chk_grb_G_end
del tsklist.txt
rem ==check button end==

tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe"
timeout /t 1 /nobreak
if %error% neq 0 exit /b %error%

rem red
DEl RED.flg
DEL BLUE.flg
DEL GREEN.flg
DEL NODIS.flg
DEL Timeout.flg
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg ff0000"
start tools\btn_rgb_str.bat
Chopper-diag.exe /delay 1000
rem if %errorlevel% equ 254 set /a error=6
rem if %errorlevel% equ 255 set /a error=255
rem if %errorlevel% neq 1 set /a error=3


:chk_grb_R
tasklist>tsklist.txt
rem check R button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_grb_R_end
rem check G button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.5 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_R_fail
rem check B button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.6 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_R_fail
rem check NO button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 1.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO dis_fail
rem IF exist btn_rgb.log set /p ERROR=<rgb.log&GOTO end
find /i "btn-diag.exe" tsklist.txt
if %errorlevel% == 0 GOTO chk_grb_R
rem ===check pass/fail by mouse click===
IF EXIST RED.flg GOTO chk_grb_R_end
IF EXIST GREEN.flg GOTO chk_R_fail
IF EXIST BLUE.flg GOTO chk_R_fail
IF EXIST NODIS.flg GOTO dis_fail
IF EXIST Timeout.flg set error=254
rem close btn-diag by OP
goto 1067
:chk_grb_R_end
del tsklist.txt
rem ==check button end==

tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe"
timeout /t 1 /nobreak
if %error% neq 0 exit /b %error%

rem blue
DEl RED.flg
DEL BLUE.flg
DEL GREEN.flg
DEL NODIS.flg
DEL Timeout.flg
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg 0000ff"
start tools\btn_rgb_str.bat
Chopper-diag.exe /delay 1000
rem if %errorlevel% equ 254 set /a error=6
rem if %errorlevel% equ 255 set /a error=255
rem if %errorlevel% neq 3 set /a error=5


:chk_grb_B
tasklist>tsklist.txt
rem check B button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.6 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_grb_B_end
rem check R button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_B_fail
rem check G button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.5 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_B_fail
rem check NO button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 1.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO dis_fail
rem IF exist btn_rgb.log set /p ERROR=<rgb.log&GOTO end
find /i "btn-diag.exe" tsklist.txt
if %errorlevel% == 0 GOTO chk_grb_B
rem ===check pass/fail by mouse click===
IF EXIST RED.flg GOTO chk_B_fail
IF EXIST GREEN.flg GOTO chk_B_fail
IF EXIST BLUE.flg GOTO chk_grb_B_end
IF EXIST NODIS.flg GOTO dis_fail
IF EXIST Timeout.flg set error=254
rem close btn-diag by OP
goto 1067
:chk_grb_B_end
del tsklist.txt
rem ==check button end==

tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe"
timeout /t 1 /nobreak
if %error% neq 0 exit /b %error%
exit /b %error%

:GBR
rem green
DEl RED.flg
DEL BLUE.flg
DEL GREEN.flg
DEL NODIS.flg
DEL Timeout.flg
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg 00ff00"
start tools\btn_rgb_str.bat
Chopper-diag.exe /delay 1000
rem if %errorlevel% equ 254 set /a error=6
rem if %errorlevel% equ 255 set /a error=255
rem if %errorlevel% neq 2 set /a error=4


:chk_gbr_G
tasklist>tsklist.txt
rem check G button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.5 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_gbr_G_end
rem check R button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_G_fail
rem check B button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.6 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_G_fail
rem check NO button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 1.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO dis_fail
rem IF exist btn_rgb.log set /p ERROR=<rgb.log&GOTO end
find /i "btn-diag.exe" tsklist.txt
if %errorlevel% == 0 GOTO chk_gbr_G
rem ===check pass/fail by mouse click===
IF EXIST RED.flg GOTO chk_G_fail
IF EXIST GREEN.flg GOTO chk_gbr_G_end
IF EXIST BLUE.flg GOTO chk_G_fail
IF EXIST NODIS.flg GOTO dis_fail
IF EXIST Timeout.flg set error=254
rem close btn-diag by OP
goto 1067
:chk_gbr_G_end
del tsklist.txt
rem ==check button end==

tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe"
timeout /t 1 /nobreak
if %error% neq 0 exit /b %error%

rem blue
DEl RED.flg
DEL BLUE.flg
DEL GREEN.flg
DEL NODIS.flg
DEL Timeout.flg
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg 0000ff"
start tools\btn_rgb_str.bat
Chopper-diag.exe /delay 1000
rem if %errorlevel% equ 254 set /a error=6
rem if %errorlevel% equ 255 set /a error=255
rem if %errorlevel% neq 3 set /a error=5


:chk_gbr_B
tasklist>tsklist.txt
rem check B button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.6 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_gbr_B_end
rem check R button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_B_fail
rem check G button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.5 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_B_fail
rem check NO button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 1.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO dis_fail
rem IF exist btn_rgb.log set /p ERROR=<rgb.log&GOTO end
find /i "btn-diag.exe" tsklist.txt
if %errorlevel% == 0 GOTO chk_gbr_B
rem ===check pass/fail by mouse click===
IF EXIST RED.flg GOTO chk_B_fail
IF EXIST GREEN.flg GOTO chk_B_fail
IF EXIST BLUE.flg GOTO chk_gbr_B_end
IF EXIST NODIS.flg GOTO dis_fail
IF EXIST Timeout.flg set error=254
rem close btn-diag by OP
goto 1067
:chk_gbr_B_end
del tsklist.txt
rem ==check button end==

tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe"
timeout /t 1 /nobreak
if %error% neq 0 exit /b %error%

rem red
DEl RED.flg
DEL BLUE.flg
DEL GREEN.flg
DEL NODIS.flg
DEL Timeout.flg
tools\LANRS-Diags.exe /e -ip %ip% -f "c:\diagtool\screen-diag.exe /display -bg ff0000"
start tools\btn_rgb_str.bat
Chopper-diag.exe /delay 1000
rem if %errorlevel% equ 254 set /a error=6
rem if %errorlevel% equ 255 set /a error=255
rem if %errorlevel% neq 1 set /a error=3


:chk_gbr_R
tasklist>tsklist.txt
rem check R button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_gbr_R_end
rem check G button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.5 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_R_fail
rem check B button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 0.6 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO chk_R_fail
rem check NO button NI pin
Tools\nicontrol-diags.exe -nl -dev dev2 /gio 1.4 0  > nul
IF %errorlevel% == 0 tskill btn-diag&GOTO dis_fail
rem IF exist btn_rgb.log set /p ERROR=<rgb.log&GOTO end
find /i "btn-diag.exe" tsklist.txt
if %errorlevel% == 0 GOTO chk_gbr_R
rem ===check pass/fail by mouse click===
IF EXIST RED.flg GOTO chk_gbr_R_end
IF EXIST GREEN.flg GOTO chk_R_fail
IF EXIST BLUE.flg GOTO chk_R_fail
IF EXIST NODIS.flg GOTO dis_fail
IF EXIST Timeout.flg set error=254
rem close btn-diag by OP
goto 1067
:chk_gbr_R_end
del tsklist.txt
rem ==check button end==

tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe"
timeout /t 1 /nobreak
if %error% neq 0 exit /b %error%
exit /b %error% 

rem ==check Red fail==
:chk_R_fail
del tsklist.txt

tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe"
timeout /t 1 /nobreak
Set /a error=3
exit /b %error% 

rem ==check green fail==
:chk_G_fail
del tsklist.txt

tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe"
timeout /t 1 /nobreak
Set /a error=4
exit /b %error% 

rem ==check blue fail==
:chk_B_fail
del tsklist.txt

tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe"
timeout /t 1 /nobreak
Set /a error=5
exit /b %error% 

rem ==Display fail==
:dis_fail
del tsklist.txt

tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe"
timeout /t 1 /nobreak
Set /a error=255
exit /b %error% 

rem ==close btn-diag by OP==
:1067
tools\LANRS-Diags.exe /e -ip %ip% -f "taskkill.exe /im screen-diag.exe"
timeout /t 1 /nobreak
IF %error% equ 254 exit /b %error%
Set /a error=1067
exit /b %error% 