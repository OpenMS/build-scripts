REM rsync setup
set HOME=c:\dev\KNIME_PACKAGE\rsync\home
set TARGET=aiche@knecht.imp.fu-berlin.de:/web/ftp.mi.fu-berlin.de/pub/OpenMS/nightly_binaries/
set RSYNC=C:\dev\KNIME_PACKAGE\rsync\rsync.exe
set SSH=C:\dev\KNIME_PACKAGE\rsync\ssh.exe
set CYGDRV=/cygdrive/c/dev/AUTO_PACKAGE/head/

call "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86
call "..\FTP_PATH.bat"

set PATH=C:\dev\AUTO_PACKAGE\head;%PATH%
set PATH=C:\dev\AUTO_PACKAGE\head\OpenMS_build32\bin\Release;%PATH%
set PATH=C:\dev\contrib_vs10_32bit\lib;%PATH%
set PATH=C:\dev\qt-4.8.4_vs10_32bit\bin;%PATH%

cd C:\dev\windows-installer

"C:\Program Files (x86)\NSIS3.0b1\makensisw" /NOCD C:\dev\AUTO_PACKAGE\head\My_Cfg_Settings_x86.nsi