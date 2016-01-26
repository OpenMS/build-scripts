CMAKE_MINIMUM_REQUIRED (VERSION 2.6)

# include general definitions
include ( ${CTEST_SCRIPT_DIRECTORY}/global.cmake )

SET (BUILD_TYPE "Debug")
SET (CTEST_SITE "microcebus.imp.fu-berlin.de")
SET (PACKAGE_TEST Off)
SET (EXTERNAL_CODE_TESTS Off)
SET (RUN_CHECKER Off)
SET (TEST_STYLE On)

# the actual test procedure
select_compiler("GCC_42")
prepare_notes()
run_tests()
