@echo on
pushd "%~dp0"

TASKKILL /IM AudioAnalyzer64-Diag.exe
TASKKILL /IM Audio64-diag.exe

:AudioR_Test
cd .\Audio-diags
del /q Audio-diag.wav
del /q Audio-diag_DMIC_R.wav
del ..\temp\Audio-diag_DMIC_R.wav

Audio64-diags.exe -setau Speakers /CHAU

rem reset Audio Condition

Audio64-diag.exe /SMVOL 0 92
timeout 1
Audio64-diag.exe /vol -100
timeout 1 
Audio64-diag.exe /vol +90
timeout 1 
Audio64-diag.exe /unmute

:DMIC
rem Play Left Channel and Record
audio64-diag.exe -r /playrec 1khz.wav

copy /y Audio-diag.wav Audio-diag_DMIC_R.wav
copy /y Audio-diag_DMIC_R.wav ..\temp\


rem Using new Audio tool to analysis
AudioAnalyzer64-Diag.exe -f Audio-diag_DMIC_R.wav -ch 2 -freq 900 1100 -fr 900 1100 -si 3 -ei 14 -thd 0 15 -db -35 3 -pi 22 /t  > ..\temp\DMIC_Audio_R_Test_Result.txt
timeout 1
exit /b 0