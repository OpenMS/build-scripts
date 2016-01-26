CMAKE_MINIMUM_REQUIRED (VERSION 2.6)

# include general definitions
include ( ${CTEST_SCRIPT_DIRECTORY}/global.cmake )

SET (BUILD_TYPE "Release")
SET (CTEST_SITE "microcebus.imp.fu-berlin.de")
SET (EXTERNAL_CODE_TESTS Off)
SET (RUN_CHECKER Off)
SET (BUILD_PYOPENMS On)
set (RUN_PYTHON_CHECKER On)
set (PACKAGE_TEST On)

# the actual test procedure
select_compiler("CLANG_SYS")
prepare_notes()
run_tests()
