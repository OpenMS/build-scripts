call "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" amd64

set PATH=C:\dev\KNIME_PACKAGE\trunk\OpenMS_build_x64\bin\Release;%PATH%
set PATH=C:\dev\contrib_vs10_64bit\lib;%PATH%
set PATH=C:\dev\qt-4.8.4_vs10_64bit\bin;%PATH%
REM set PATH=C:\Program Files (x86)\Java\jre7\bin;%PATH%

echo "Starting OpenMS x64 KNIME Package Build %DATE%-%TIME%"

REM build Fido from our adapted sources
pushd C:\dev\fido\fido-build-VS10-64bit
cmake -G "Visual Studio 10 Win64" "../"
IF %ERRORLEVEL% NEQ 0 goto bad_error
rmdir /S /Q Release
devenv fido.sln /Build "Release|x64"
IF %ERRORLEVEL% NEQ 0 goto bad_error
copy /Y Release\Fido.exe %SEARCHENGINE_ROOT%\64bit\Fido\
copy /Y Release\FidoChooseParameters.exe %SEARCHENGINE_ROOT%\64bit\Fido\
popd

REM cmake
mkdir OpenMS_build_x64
pushd OpenMS_build_x64
cmake -D ENABLE_PREPARE_KNIME_PACKAGE=On -D SEARCH_ENGINES_DIRECTORY=%SEARCHENGINE_ROOT%\64bit\ -D CMAKE_PREFIX_PATH:FILEPATH=%CONTRIB_ROOT%\contrib_vs10_64bit -G "Visual Studio 10 Win64" %OPENMS_SOURCE%
IF %ERRORLEVEL% NEQ 0 goto bad_error
REM Clean old binaries
rmdir /S /Q bin\Release
popd

REM Build OpenMS
devenv OpenMS_build_x64/OpenMS_host.sln /Build "Release" /Project TOPP
IF %ERRORLEVEL% NEQ 0 goto bad_error
devenv OpenMS_build_x64/OpenMS_host.sln /Build "Release" /Project UTILS
IF %ERRORLEVEL% NEQ 0 goto bad_error
devenv OpenMS_build_x64/OpenMS_host.sln /Build "Release" /Project prepare_knime_package
IF %ERRORLEVEL% NEQ 0 goto bad_error


REM copy the resulting package structure
C:\dev\KNIME_PACKAGE\rsync\rsync.exe --chmod=ugo=rwX --chmod=o=rx -avz --rsh "C:\dev\KNIME_PACKAGE\rsync\ssh.exe" /cygdrive/c/dev/KNIME_PACKAGE/trunk/OpenMS_build_x64/ctds/ %TARGET%/win64

cd C:\dev\KNIME_PACKAGE\trunk\

echo "Finished OpenMS x64 KNIME Package Build %DATE%-%TIME%"

exit /B 0

:bad_error
@echo An error occured. Exiting
exit /B 1

