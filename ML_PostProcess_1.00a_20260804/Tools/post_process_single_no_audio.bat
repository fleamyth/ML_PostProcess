post_process.exe --debug --skip_audio=True --config=robocalv4_config_pre_post.yaml %1 %2 %3
echo %errorlevel%
pause
exit /b %errorlevel%
