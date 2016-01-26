## CMake Nightly Build Scripts for Windows
## (c) 2013 Stephan Aiche

include("${CTEST_SCRIPT_DIRECTORY}/compilers.cmake")
include("${CTEST_SCRIPT_DIRECTORY}/selector.cmake")
include("${CTEST_SCRIPT_DIRECTORY}/global.cmake")

select_vs_version("VS12" "x86")
set(BUILD_TYPE "Debug")
set(EXTERNAL_CODE_TESTS On)
run_nightly()