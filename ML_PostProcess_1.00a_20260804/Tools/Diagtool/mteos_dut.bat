@echo off
c:\windows\system32\reg.exe query "hklm\software\microsoft\windows\currentversion" /v imagename > c:\diagtool\mteos.log
exit /b %errorlevel%

