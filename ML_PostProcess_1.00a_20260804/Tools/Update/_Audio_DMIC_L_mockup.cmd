@echo on
pushd "%~dp0"

TASKKILL /IM AudioAnalyzer64-Diag.exe
TASKKILL /IM Audio64-diag.exe

:AudioL_Test
cd .\Audio-diags
del /q Audio-diag.wav
del /q Audio-diag_DMIC_L.wav
del ..\temp\Audio-diag_DMIC_L.wav

Audio64-diags.exe -setau Speakers /CHAU

rem reset Audio Condition

Audio64-diag.exe /SMVOL 0 92
timeout 1
Audio64-diag.exe /vol -100
timeout 1 
Audio64-diag.exe /vol +70
timeout 1 
Audio64-diag.exe /unmute

:DMIC
rem Play Left Channel and Record
audio64-diag.exe -l /playrec 1khz.wav

copy /y Audio-diag.wav Audio-diag_DMIC_L.wav
copy /y Audio-diag_DMIC_L.wav ..\temp\


rem Using new Audio tool to analysis
AudioAnalyzer64-Diag.exe -f Audio-diag_DMIC_L.wav -ch 1 -freq 900 1100 -fr 900 1100 -si 3 -ei 14 -thd 0 10 -db -35 0 -pi 22 /t  > ..\temp\DMIC_Audio_L_Test_Result.txt
timeout 1
exit /b 0