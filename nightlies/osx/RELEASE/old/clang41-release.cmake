CMAKE_MINIMUM_REQUIRED (VERSION 2.6)

# include general definitions
include ( ${CTEST_SCRIPT_DIRECTORY}/global.cmake )

SET (BUILD_TYPE "Release")
SET (CTEST_SITE "microcebus.imp.fu-berlin.de")
SET (PACKAGE_TEST On)
SET (EXTERNAL_CODE_TESTS On)
SET (RUN_CHECKER Off)

# the actual test procedure
select_compiler("CLANG_41")
prepare_notes()
run_tests()
