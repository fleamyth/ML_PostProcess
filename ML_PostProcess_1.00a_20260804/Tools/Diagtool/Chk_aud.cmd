@echo on
cd %~dp0

set CHKAUD_LOG=".\CHKAUD_DEV.log"
if exist ".\CHKAUD_DEV.log" del ".\CHKAUD_DEV.log"
set Remark=0

:RGB_test
cd .\
Audio-diag.exe /LD > %CHKAUD_LOG%
Audio-diag.exe /chkact "%1"
if %errorlevel% neq 0 goto fail

:pass
echo pass > CHKACT.log
goto end

:fail
echo fail > CHKACT.log
set Remark=1

:end
popd
if %Remark%==1 exit /b 255
exit /b 0