@echo off
set /a count=0

:start
set /a count=%count%+1
Tools\Audio_GetValue.bat %1 %2 %3 %4 %5 %6
set error=%errorlevel%
if %error% equ 0 exit /b 0
if %count% equ 3 exit /b %error%
if "%4" equ "L" goto replay_L
if "%4" equ "R" goto replay_R

:replay_L
Tools\Audio-diag.exe -spk -fmic -amp 0.15 -ampr 0.15 -time 5 -t 3 /lr 1000 0
goto start

:replay_R
Tools\Audio-diag.exe -spk -fmic -amp 0.3 -ampr 0.3 -time 5 -t 3 /LR 0 2000
goto start