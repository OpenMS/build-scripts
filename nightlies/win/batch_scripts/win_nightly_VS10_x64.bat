REM call nightly test builds for win8

call "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" amd64                                                             
echo %PATH%

set LOG_PATH=C:\dev\NIGHTLY\logs
set SCRIPT_PATH=C:\dev\NIGHTLY\scripts

REM we change into to the script directory
pushd %SCRIPT_PATH%

ctest -S vs10_x64_Release.cmake -C Release -V > %LOG_PATH%\vs10_x64_Release.cmake.log
ctest -S vs10_x64_Debug.cmake -C Debug -V > %LOG_PATH%\vs10_x64_Debug.cmake.log

popd
