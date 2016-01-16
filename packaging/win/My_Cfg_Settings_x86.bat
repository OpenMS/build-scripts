call "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86
call "..\FTP_PATH.bat"

set PATH=C:\dev\AUTO_PACKAGE\head;%PATH%
set PATH=C:\dev\AUTO_PACKAGE\head\OpenMS_build32\bin\Release;%PATH%
set PATH=C:\dev\contrib_vs10_32bit\lib;%PATH%
set PATH=C:\dev\qt-4.8.4_vs10_32bit\bin;%PATH%

REM build Fido from our adapted sources
pushd C:\dev\fido\fido-build-VS10-32bit
cmake -G "Visual Studio 10" "../"
IF %ERRORLEVEL% NEQ 0 goto bad_error
rmdir /S /Q Release
devenv fido.sln /Build "Release"
IF %ERRORLEVEL% NEQ 0 goto bad_error

REM copy Fido executables to other 3rd party execs
copy /Y Release\Fido.exe C:\dev\windows-installer\third_party\to_install\32bit\Fido\
copy /Y Release\FidoChooseParameters.exe C:\dev\windows-installer\third_party\to_install\32bit\Fido\
popd

REM cmake
mkdir OpenMS_build32
cd OpenMS_build32
cmake -D CMAKE_FIND_ROOT_PATH="C:\dev\contrib_vs10_32bit" -G "Visual Studio 10" "../OpenMS"
IF %ERRORLEVEL% NEQ 0 goto bad_error
rmdir /S /Q bin\Release
cd..

REM Build OpenMS
devenv OpenMS_build32/OpenMS_host.sln /Build "Release" /Project TOPP
IF %ERRORLEVEL% NEQ 0 goto bad_error
devenv OpenMS_build32/OpenMS_host.sln /Build "Release" /Project UTILS
IF %ERRORLEVEL% NEQ 0 goto bad_error
devenv OpenMS_build32/OpenMS_host.sln /Build "Release" /Project GUI
IF %ERRORLEVEL% NEQ 0 goto bad_error
devenv OpenMS_build32/OpenMS_host.sln /Build "Release" /Project doc
IF %ERRORLEVEL% NEQ 0 goto bad_error
devenv OpenMS_build32/OpenMS_host.sln /Build "Release" /Project doc_tutorials
IF %ERRORLEVEL% NEQ 0 goto bad_error

REM build the installer
cd C:\dev\windows-installer

git fetch origin
IF %ERRORLEVEL% NEQ 0 goto bad_error
git merge --ff-only origin/master
IF %ERRORLEVEL% NEQ 0 goto bad_error

"C:\Program Files (x86)\NSIS3.0b1\makensis" /NOCD C:\dev\AUTO_PACKAGE\head\My_Cfg_Settings_x86.nsi
IF %ERRORLEVEL% NEQ 0 goto bad_error

REM copy the resulting setup:
copy /Y C:\dev\windows-installer\OpenMS-head_Win32_setup.exe C:\dev\AUTO_PACKAGE\head\

REM rsync file to target
%RSYNC% -avz --chmod=ugo=rwX --chmod=o=rx --rsh "%SSH%" %CYGDRV%OpenMS-head_Win32_setup.exe %TARGET%OpenMS-head_Win32_setup.exe

exit /B 0

:bad_error
@echo An error occured. Exiting
exit /B 1
