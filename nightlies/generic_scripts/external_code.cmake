## Should not happen if called from mainscript. remove and/or add warning if called alone
if(NOT DEFINED TEST_MACROS_INCLUDED)
  include(${SCRIPT_PATH}/test_macros.cmake)
endif()

# Check for required variables.
set(required_variables "CTEST_SOURCE_DIRECTORY;CTEST_BINARY_DIRECTORY;INITIAL_CACHE;CTEST_BUILD_NAME")

backup_and_check_variables(required_variables)

if(NOT DEFINED CDASH_SUBMIT)
    set(CDASH_SUBMIT Off)
endif()
if(NOT DEFINED DASHBOARD_MODEL)
    set(DASHBOARD_MODEL Experimental)
endif()


## external project:
SET (CTEST_SOURCE_TESTEXTERNAL_DIRECTORY "${CTEST_SOURCE_DIRECTORY}/src/tests/external/")
SET (CTEST_BINARY_TESTEXTERNAL_DIRECTORY "${CTEST_BINARY_DIRECTORY}/source/TEST/EXTERNAL/")

SET (CTEST_ENVIRONMENT "OPENMS_BUILD_TREE=${CTEST_BINARY_DIRECTORY}")

## extend initial cache with references to
## the OpenMS directory
## TODO Figure out, why only on Mac, OpenMS_DIR:PATH=${CTEST_BINARY_DIRECTORY}/cmake is added.
SET(INITIAL_CACHE "${INITIAL_CACHE}
")

## (re)define build name and test directories
SET (CTEST_BUILD_NAME "${CTEST_BUILD_NAME}_External")
SET (CTEST_SOURCE_DIRECTORY ${CTEST_SOURCE_TESTEXTERNAL_DIRECTORY})
SET (CTEST_BINARY_DIRECTORY ${CTEST_BINARY_TESTEXTERNAL_DIRECTORY})

SET (CTEST_PROJECT_NAME "OpenMS_external_code_test")

CTEST_EMPTY_BINARY_DIRECTORY (${CTEST_BINARY_DIRECTORY})

FILE(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${INITIAL_CACHE})

CTEST_START (${DASHBOARD_MODEL} TRACK ExternalCode)

# In version 3.1.0, CTEST_UPDATE_VERSION_ONLY was introduced.
# With this we can use the Jenkins Git plugin for the checkout and only get the version for CDash 
# Otherwise skip update completely
if(NOT "${CMAKE_VERSION}" VERSION_LESS 3.1.0)
 SET(CTEST_UPDATE_VERSION_ONLY On)
 CTEST_UPDATE(SOURCE "${CTEST_SOURCE_DIRECTORY}")
endif()
CTEST_CONFIGURE (BUILD "${CTEST_BINARY_TESTEXTERNAL_DIRECTORY}")
CTEST_BUILD     (BUILD "${CTEST_BINARY_TESTEXTERNAL_DIRECTORY}")
CTEST_TEST      (BUILD "${CTEST_BINARY_TESTEXTERNAL_DIRECTORY}")
if(CDASH_SUBMIT)
  CTEST_SUBMIT    (PARTS Configure Build Test)
endif()

restore_variables(required_variables)
