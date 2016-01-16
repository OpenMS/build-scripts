## CMake Nightly Build Scripts for Windows
## (c) 2015 Stephan Aiche and Julianus Pfeuffer

include("${CTEST_SCRIPT_DIRECTORY}/compilers.cmake")
include("${CTEST_SCRIPT_DIRECTORY}/selector.cmake")

set(SCRIPT_PATH "${CTEST_SCRIPT_DIRECTORY}")

## Prefix for all builds (e.g., to distinguish between HEAD and Release-branch)
SET (OPENMS_BUILDNAME_PREFIX @buildname_prefix@)

## Path where the nightly builds will be build
SET (BUILD_DIRECTORY @build_dir@)

# Describe your system as it will be shown in CDash
set(SYSTEM_IDENTIFIER @system_identifier@)
set(CTEST_SITE @site@)

## Path to a valid checkout corresponding to the above selected
## branch
set(CTEST_SOURCE_DIRECTORY @source_dir@ )
set(CTEST_GIT_COMMAND @git_command@)
set(CTEST_UPDATE_COMMAND ${CTEST_GIT_COMMAND})
set(CTEST_COMMAND @ctest_command@)
set(CMAKE_COMMAND @cmake_command@)

select_vs_version(@vs@ @arch@)
set(CONTRIB @contrib@)
set(BUILD_TYPE @build_type@)
set(EXTERNAL_CODE_TESTS @code_tests@)
set(RERUN Off)
run_nightly()
