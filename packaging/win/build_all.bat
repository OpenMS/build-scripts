REM rsync setup
set HOME=c:\dev\KNIME_PACKAGE\rsync\home
set TARGET=jpfeuffer@knecht.imp.fu-berlin.de:/web/ftp.imp.fu-berlin.de/pub/OpenMS/nightly_binaries/
set RSYNC=C:\dev\KNIME_PACKAGE\rsync\rsync.exe
set SSH=C:\dev\KNIME_PACKAGE\rsync\ssh.exe
set CYGDRV=/cygdrive/c/dev/AUTO_PACKAGE/head/

cd C:\dev\AUTO_PACKAGE\head\OpenMS
REM update OpenMS
echo "update OpenMS git repo"
git fetch origin
git merge --ff-only origin/develop
IF %ERRORLEVEL% NEQ 0 goto bad_error
cd C:\dev\AUTO_PACKAGE\head

cd C:\dev\AUTO_PACKAGE\head
call My_Cfg_Settings_x86.bat > log_x86_head.txt 2>&1
cd C:\dev\AUTO_PACKAGE\head
%RSYNC% -avz --chmod=ugo=rwX --chmod=o=rx --rsh "%SSH%" %CYGDRV%log_x86_head.txt %TARGET%log_x86_head.txt


cd C:\dev\AUTO_PACKAGE\head
call My_Cfg_Settings_x64.bat > log_x64_head.txt 2>&1
cd C:\dev\AUTO_PACKAGE\head
%RSYNC% -avz --chmod=ugo=rwX --chmod=o=rx --rsh "%SSH%" %CYGDRV%log_x64_head.txt %TARGET%log_x64_head.txt
