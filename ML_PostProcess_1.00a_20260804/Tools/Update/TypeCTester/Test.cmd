@echo off
::这是一个可以循环1000次的批处理

set ymd=%date:~0,4%%date:~5,2%%date:~8,2%
set hm=%time:~0,2%%time:~3,2%
set FailCnt=0
set ExeName=TBT01Tester.exe
set DmpName=TypeC2605Tester.dmp
set /p TestTimes=请输入测试次数
mkdir DUMP_%ymd%>nul
echo.
time/t
echo 测试开始

:loop
timeout /T 5 /NOBREAK
set /a startTime=%time:~0,2%*360000+%time:~3,2%*6000+%time:~6,2%*100+%time:~9,2%
%ExeName%
set ExeErr=%errorlevel%
time/t
set /a spenTime=%time:~0,2%*360000+%time:~3,2%*6000+%time:~6,2%*100+%time:~9,2%-%startTime%
set /a num+=1
if %ExeErr% neq 0 (
	set /a FailCnt+=1
	echo 本次测试失败！
)
echo 第 %num% 次运行结束，耗时耗时%spenTime:~0,-2%.%spenTime:~-2%s, 总共失败: %FailCnt% 次
echo %time:~0,8%-第 %num% 次运行结束,耗时%spenTime:~0,-2%.%spenTime:~-2%s, 总共失败: %FailCnt% 次>>".\DUMP_%ymd%\text_%hm%.txt"
if exist .\%DmpName% (
	echo 程序运行出错
	echo 程序运行出错>>".\DUMP_%ymd%\text_%hm%.txt"
	move "%DmpName%" ".\DUMP_%ymd%\DHVTR_%hm%_%num%.dmp" >nul
)
echo.
if %num% equ %TestTimes% (
	goto exit
)
goto loop

:exit
time/t
echo 测试结束
echo 测试截止于 %time% 总共测试 %num% 次，失败 %FailCnt% 次>>".\DUMP_%ymd%\text_%hm%.txt"
echo ===============================>>".\DUMP_%ymd%\text_%hm%.txt"
pause