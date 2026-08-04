@echo off
cd %~dp0
Memory-diag.exe -p 50 /t > MemTest.log
exit /b %errorlevel%