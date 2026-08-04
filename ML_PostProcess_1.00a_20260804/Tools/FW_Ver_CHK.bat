SET MISC=C:\MISClog\Debug
IF EXIST MISClog.dat SET /p MISC=<MISClog.dat
SET TestItem=FW_VER_CHK
SET Log=FW_VER_CHK.log
IF EXIST sn.dat SET /p SN=<sn.dat
IF EXIST TSRID.dat SET /p TSRID=<TSRID.dat


del %log%
rem del execute.flg
rem goto End
:USB30
call tools\Dock_fwupdate\CheckVersions.cmd >FW_VER_CHK.log
if %errorlevel% equ 0 goto Passlog

find /i "Chip 0x15 (USB Downstream)" FW_VER_CHK.log >Fail_FW.log
find /i "6.3.83" Fail_FW.log
if %errorlevel% neq 0 goto Faillog

find /i "Chip 0x14 (USB Upstream)" FW_VER_CHK.log >Fail_FW.log
find /i "6.3.73" Fail_FW.log
if %errorlevel% neq 0 goto Faillog

find /i "Chip 0x12 (Power Distribution)" FW_VER_CHK.log >Fail_FW.log
find /i "1.4.1" Fail_FW.log
if %errorlevel% neq 0 goto Faillog

find /i "Chip 0x00 (MCU)" FW_VER_CHK.log >Fail_FW.log
find /i "5.19.139" Fail_FW.log
if %errorlevel% neq 0 goto Faillog

find /i "Chip 0x13 (Display Port)" FW_VER_CHK.log >Fail_FW.log
find /i "5.4.211" Fail_FW.log
if %errorlevel% neq 0 goto Faillog

find /i "Chip 0x11 (Realtek Audio)" FW_VER_CHK.log >Audio_FW.log
find /i "22.0.0" Audio_FW.log
if %errorlevel% equ 0 goto Passlog

:Faillog
SET EXIT_PF=FAIL
GOTO Fbackup

:Passlog
SET EXIT_PF=PASS

:Pbackup
rem IF NOT EXIST %Log% GOTO END
tools\LogTransfer-auto.exe -nl /de -
call setdate.bat
SET DEST=%TestItem%\%datepath%\%EXIT_PF%
IF NOT EXIST %MISC%\%DEST% MKDIR %MISC%\%DEST%
Copy %Log% %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%_FWVER_CHK.log
Copy Audio_FW.log %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%_AUDFW_CHK.log

:End

EXIT /B 0

:Fbackup
rem IF NOT EXIST %Log% GOTO END
tools\LogTransfer-auto.exe -nl /de -
call setdate.bat
SET DEST=%TestItem%\%datepath%\%EXIT_PF%
IF NOT EXIST %MISC%\%DEST% MKDIR %MISC%\%DEST%
Copy %Log% %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%_FWVER_CHK.log
Copy Audio_FW.log %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%_AUDFW_CHK.log
Copy Fail_FW.log %MISC%\%DEST%\%SN%_%TSRID%_%TestItem%_%EXIT_PF%_Fail_FW.log

:End
del execute.flg
echo execute > execute.flg
EXIT /B 255