CMAKE_MINIMUM_REQUIRED (VERSION 2.6)

# include general definitions
include ( ${CTEST_SCRIPT_DIRECTORY}/global.cmake )

SET (BUILD_TYPE "Release")
SET (CTEST_SITE "knecht.imp.fu-berlin.de")
SET (PACKAGE_TEST Off)
SET (EXTERNAL_CODE_TESTS On)
SET (RUN_CHECKER Off)
#SET (RERUN On)

# the actual test procedure
select_compiler("GCC_48")
prepare_notes()
run_tests()
