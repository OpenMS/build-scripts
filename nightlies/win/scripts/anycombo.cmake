## CMake Nightly Build Scripts for Windows
## (c) 2013 Stephan Aiche

include("${CTEST_SCRIPT_DIRECTORY}/compilers.cmake")
include("${CTEST_SCRIPT_DIRECTORY}/selector.cmake")
include("${CTEST_SCRIPT_DIRECTORY}/global.cmake")

select_vs_version(@vs@ @arch@)
set(CONTRIB @contrib@)
set(BUILD_TYPE @build_type@)
set(EXTERNAL_CODE_TESTS @code_tests@)
run_nightly()