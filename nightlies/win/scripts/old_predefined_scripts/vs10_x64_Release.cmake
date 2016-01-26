## CMake Nightly Build Scripts for Windows
## (c) 2013 Stephan Aiche

include("${CTEST_SCRIPT_DIRECTORY}/compilers.cmake")
include("${CTEST_SCRIPT_DIRECTORY}/selector.cmake")
include("${CTEST_SCRIPT_DIRECTORY}/global.cmake")

select_vs_version("VS10" "x64")
set(BUILD_TYPE "Release")
set(EXTERNAL_CODE_TESTS OFF)
run_nightly()