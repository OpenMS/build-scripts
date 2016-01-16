call FTP_PATH.bat
REM rsync file to target
%RSYNC% -avz --chmod=ugo=rwX --chmod=o=rx --rsh "%SSH%" %CYGDRV%OpenMS-head_Win64_setup.exe %TARGET%OpenMS-head_Win64_setup.exe
