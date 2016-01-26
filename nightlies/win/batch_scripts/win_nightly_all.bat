REM call nightly test builds for win8
set LOG_PATH=C:\dev\NIGHTLY\logs

REM call test drivers for the individual VS + ARCH combinations
call win_nightly_VS10_x64.bat > %LOG_PATH%\win_nightly_VS10_x64_host.log
REM call win_nightly_VS10_x86.bat > %LOG_PATH%\win_nightly_VS10_x86_host.log
REM call win_nightly_VS12_x64.bat > %LOG_PATH%\win_nightly_VS12_x64_host.log
call win_nightly_VS12_x86.bat > %LOG_PATH%\win_nightly_VS12_x86_host.log
