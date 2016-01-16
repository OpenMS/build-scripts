set CONTRIB_ROOT=C:\dev
set SEARCHENGINE_ROOT=C:\dev\windows-installer\third_party\to_install

call ..\global_variables.bat

REM rsync setup
set TARGET=%GLOBAL_RSYNC_TARGET%_TRUNK/assembly/
set OPENMS_SOURCE=C:\dev\KNIME_PACKAGE\trunk\OpenMS

cd C:\dev\KNIME_PACKAGE\trunk\

REM update OpenMS
pushd %OPENMS_SOURCE%

git fetch origin
REM IF %ERRORLEVEL% NEQ 0 goto bad_error
git merge --ff-only origin/develop
REM IF %ERRORLEVEL% NEQ 0 goto bad_error

popd

call package_x86.bat > log_x86_release.txt 2>&1

cd C:\dev\KNIME_PACKAGE\trunk

call package_x64.bat > log_x64_release.txt 2>&1

exit /B 0

:bad_error
@echo An error occured. Exiting
exit /B 1