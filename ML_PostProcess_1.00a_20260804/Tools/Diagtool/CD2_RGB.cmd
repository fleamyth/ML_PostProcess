@echo on
cd %~dp0

set RGB_LOG=".\CD2_RGB.log"
if exist ".\CD2_RGB.log" del ".\CD2_RGB.log"
set Remark=0

:RGB_test
cd .\
Video-diags.exe /RGB
if %errorlevel% neq 0 goto fail

:pass
echo pass > %RGB_LOG%
goto end

:fail
echo fail > %RGB_LOG%
set Remark=1

:end
popd
if %Remark%==1 exit /b 255
exit /b 0