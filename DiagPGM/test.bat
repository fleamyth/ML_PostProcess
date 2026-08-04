echo %~dp0
set a=0
set b=0
if %a% EQU 0 set b=1 & goto c
echo non
pause

:c
echo %b%
pause