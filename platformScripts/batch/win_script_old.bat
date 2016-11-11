setlocal EnableExtensions EnableDelayedExpansion

REM The source files
set "SOURCE_PATH=%WORKSPACE%\source"

REM The build files
set "BUILD_PATH=%WORKSPACE%\build"
mkdir "%BUILD_PATH%"

REM The log files
set "LOG_PATH=%WORKSPACE%\logs"
mkdir "%LOG_PATH%"

REM Unzip contrib_build and omit listing of every file
"%ZIP%" e contrib_build.tar.gz -y > "%LOG_PATH%\contrib_extraction.log"
"%ZIP%" x contrib_build.tar -y >> "%LOG_PATH%\contrib_extraction.log"
set CONTRIB_PATH=%WORKSPACE%\contrib_build
set CONTRIB_PATH_CMAKE=%CONTRIB_PATH:\=/%

REM Be safe and replace \ with / for CMake
set WORKSPACE_CMAKE=%WORKSPACE:\=/%

REM set another architecture name and the Visual Studio suffix resulting from it.
set arch=x86
set vs_arch=
set arch_bit=32bit
set arch_no_bit=32

IF %platform% == amd64 (
   set arch=x64
   set arch_bit=64bit
   set arch_no_bit=64
   REM Note the leading whitespace for use in the Generator
   set vs_arch= Win64
)

echo ARCH_NO_BIT=%arch_no_bit% >> env.properties


REM Note the inconsistency starting at 11
IF "%vs_version%"=="10" set vs_year=2010
IF "%vs_version%"=="11" set vs_year=2012
IF "%vs_version%"=="12" set vs_year=2013
IF "%vs_version%"=="14" set vs_year=2015

REM e.g. for origin/master or tags/release2.0.0 to master or release2.0.0
for %%a in (%GIT_BRANCH:/= %) do set LAST_BRANCH_PART=%%a
echo %LAST_BRANCH_PART%

set "GENERATOR=Visual Studio %vs_version%%vs_arch%"
echo GeneratorString:
echo %GENERATOR%

REM get correct QT Path. QT_VERSIONS_PATH has to be set for the machine and all versions for QT4 have to be installed there.
REM Caution on win8_vm_Berlin! Someone crazy named the folders according to the ending of the VS year (e.g. vs12 is version 11, vs13 is version 12, vs10 is version 10)
@powershell -Command "Get-ChildItem %QT_VERSIONS_PATH% qt-4*_vs%vs_version%_%arch_bit% | Select-Object -First 1 | %% { Write-Host $_.FullName }" > qtloc_tmp.txt
set /p QT_PATH=<qtloc_tmp.txt

echo "Chose following Path for QT:"
echo %QT_PATH%
set QT_PATH_CMAKE=%QT_PATH:\=/%

REM to get Thirdparty executables
REM TODO think about setting up local repo on each machine and only update here. Same for other OS and other repos (e.g. build-scripts)
set "SEARCHENGINES=%WORKSPACE%\SEARCHENGINES"
mkdir %SEARCHENGINES%
set SEARCHENGINES_CMAKE=%SEARCHENGINES:\=/%
echo %SEARCHENGINES_CMAKE%

REM Get the revision that would be checked out
git ls-remote https://github.com/OpenMS/THIRDPARTY master > %SEARCHENGINES%\tmpCommit.txt
REM Compare with current revision
FC %SEARCHENGINES%\latestCommit.txt %SEARCHENGINES%\tmpCommit.txt

REM If the checked out hash is not the same as the latest on the master branch:
if errorlevel 1 (
svn export --force https://github.com/OpenMS/THIRDPARTY/branches/master/All %SEARCHENGINES% > "%LOG_PATH%\git.log"
svn export --force https://github.com/OpenMS/THIRDPARTY/branches/master/Windows/%arch_bit% %SEARCHENGINES% >> "%LOG_PATH%\git.log"
mv %SEARCHENGINES%\tmpCommit.txt %SEARCHENGINES%\latestCommit.txt
) else (
rm %SEARCHENGINES%\tmpCommit.txt
)

REM Scripts from github.com/OpenMS/build-scripts

set "GIT_SCRIPT_PATH=%WORKSPACE%\scripts"
echo %GIT_SCRIPT_PATH%

set GIT_SCRIPT_PATH_CMAKE=%GIT_SCRIPT_PATH:\=/%

REM Try pulling changes for scripts on git (not needed. we do full export each time for now)
REM Note: git -C requires a late version of Git (don't remember which)
REM git -C %GIT_SCRIPT_PATH% pull

REM Download nightly scripts
svn export --force https://github.com/OpenMS/build-scripts/branches/master/nightlies/generic_scripts %GIT_SCRIPT_PATH% >> "%LOG_PATH%\git.log"

REM we change into to the script directory for the nightlies
pushd %GIT_SCRIPT_PATH%

REM make copy from the template
cp test_config.cmake.template mycombo.cmake

REM setup variables to fill the CMake Template test_config.cmake.template

REM TODO Think about requiring Jenkins variables for all the programs.
REM I hate windows batch

FOR /F "tokens=* USEBACKQ" %%F IN (`where git`) DO (
SET GIT=%%F
)
echo %GIT%
set GIT_CMAKE=%GIT:\=/%

FOR /F "tokens=* USEBACKQ" %%F IN (`where cmake`) DO (
SET CMAKE_BIN_PATH=%%~pF
)
SET CMAKE_BIN_PATH=C:%CMAKE_BIN_PATH%
echo %CMAKE_BIN_PATH%
set CMAKE_BIN_PATH_CMAKE=%CMAKE_BIN_PATH:\=/%

FOR /F "tokens=* USEBACKQ" %%F IN (`where make`) DO (
SET MAKE_BIN_PATH=%%~pF
)
SET MAKE_BIN_PATH=C:%MAKE_BIN_PATH%
echo %MAKE_BIN_PATH%
set MAKE_BIN_PATH_CMAKE=%MAKE_BIN_PATH:\=/%

REM read out computername and domain (e.g. scratchy.imp.fu-berlin.de)
FOR /F "tokens=2" %%i in ('systeminfo ^| find /i "Domain"') DO (
SET COMPUTER_DOMAIN=%computername%.%%i
)
echo %COMPUTER_DOMAIN%
echo %NODE_NAME%

if NOT "%skip_tests%" == "true" (
REM Create a cmake script for the current configuration.
@powershell -Command "(gc mycombo.cmake) -replace '@contrib_dir@','""%CONTRIB_PATH_CMAKE%""" ' > mycombo1.cmake"
@powershell -Command "(gc mycombo1.cmake) -replace '@vs@','""VS%vs_version%""" ' > mycombo.cmake"
@powershell -Command "(gc mycombo.cmake) -replace '@arch@','""%arch%""" ' > mycombo1.cmake"
@powershell -Command "(gc mycombo1.cmake) -replace '@build_type@','""%build_type%""" ' > mycombo.cmake"
@powershell -Command "(gc mycombo.cmake) -replace '@external_code_tests@','""%external_code_tests%""" ' > mycombo1.cmake"
@powershell -Command "(gc mycombo1.cmake) -replace '@source_dir@','""%WORKSPACE_CMAKE%/source""" ' > mycombo.cmake"
@powershell -Command "(gc mycombo.cmake) -replace '@build_dir@','""%WORKSPACE_CMAKE%/build""" ' > mycombo1.cmake"
@powershell -Command "(gc mycombo1.cmake) -replace '@buildname_prefix@','""%LAST_BRANCH_PART%""" ' > mycombo.cmake"
@powershell -Command "(gc mycombo.cmake) -replace '@system_identifier@','""%NODE_NAME%""" ' > mycombo1.cmake"
@powershell -Command "(gc mycombo1.cmake) -replace '@ctest_site@','""%COMPUTER_DOMAIN%""" ' > mycombo.cmake"
@powershell -Command "(gc mycombo.cmake) -replace '@git_command@','""%GIT_CMAKE%""" ' > mycombo1.cmake"
@powershell -Command "(gc mycombo1.cmake) -replace '@cmake_bin_path@','""%CMAKE_BIN_PATH_CMAKE%""" ' > mycombo.cmake"
@powershell -Command "(gc mycombo.cmake) -replace '@script_path@','""%GIT_SCRIPT_PATH_CMAKE%""" ' > mycombo1.cmake"
REM @powershell -Command "(gc mycombo1.cmake) -replace '@compiler_cmake@','""%GIT_SCRIPT_PATH_CMAKE%/compilers_win.cmake""" ' > mycombo.cmake"
@powershell -Command "(gc mycombo1.cmake) -replace '@thirdparty_root@','""%SEARCHENGINES_CMAKE%""" ' > mycombo.cmake"
@powershell -Command "(gc mycombo.cmake) -replace '@qmake_bin_path@','""%QT_PATH_CMAKE%/bin""" ' > mycombo1.cmake"
@powershell -Command "(gc mycombo1.cmake) -replace '@generator@','""%GENERATOR%""" ' > mycombo.cmake"
@powershell -Command "(gc mycombo.cmake) -replace '@cdash_submit@','""%cdash_submit%""" ' > mycombo1.cmake"
@powershell -Command "(gc mycombo1.cmake) -replace '@make_path@','""%MAKE_BIN_PATH_CMAKE%/make.exe""" ' > mycombo.cmake"
@powershell -Command "(gc mycombo.cmake) -replace '@compiler_id@','""MSVC%vs_version%%arch%""" ' > mycombo1.cmake"
@powershell -Command "(gc mycombo1.cmake) -replace '@knime_test@','""%knime_test%""" ' > mycombo.cmake"
@powershell -Command "(gc mycombo.cmake) -replace '@number_threads@','""2""" ' > mycombo1.cmake"
@powershell -Command "(gc mycombo1.cmake) -replace '@latex_path@','""%LATEX_ROOT:\=/%""" ' > mycombo.cmake"

echo EXECUTING the following make script with ctest:
echo ##############################################################################
more mycombo.cmake
echo ##############################################################################

REM Load in correct environment
call "C:\Program Files (x86)\Microsoft Visual Studio %vs_version%.0\VC\vcvarsall.bat" %platform%

ctest -S mycombo1.cmake -C %build_type% -V 
REM > %LOG_PATH%\vs%vs_version%_%arch%_%build_type%.cmake.log

popd
