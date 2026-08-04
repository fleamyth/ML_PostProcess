:scancode
set count=0
:scan
set /a count+=1
SNAPI-diags.exe -nl -t 5 /SCAN ..\SN_A.dat 
IF %ERRORLEVEL% EQU 0 goto scandone
IF %count% LEQ 3 Screen-diag.exe -enter /ss 80 "Check Scanner Status<br> <br>Try Again !!!" 0xFFFFFF -bg 0xFF7F25 & GOTO scan
Screen-diag.exe -enter /ss 80 "Scanner Error <br> <br>Call FE for HELP" 0xFFFFFF -bg 0x667FFF & GOTO scancode
:scandone
exit /b
