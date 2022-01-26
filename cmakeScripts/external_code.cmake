## Should not happen if called from mainscript. remove and/or add warning if called alone
if(NOT DEFINED TEST_MACROS_INCLUDED)
  include(${OPENMS_CMAKE_SCRIPT_PATH}/test_macros.cmake)
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
SET (CTEST_BINARY_TESTEXTERNAL_DIRECTORY "${CTEST_BINARY_DIRECTORY}/src/tests/external/")
file(COPY "${CTEST_SOURCE_DIRECTORY}/CTestConfig.cmake" DESTINATION "${CTEST_BINARY_TESTEXTERNAL_DIRECTORY}")

SET (CTEST_ENVIRONMENT "OPENMS_BUILD_TREE=${CTEST_BINARY_DIRECTORY}")
SET (OpenMS_DIR "${CTEST_BINARY_DIRECTORY}")

## extend initial cache with references to
## the OpenMS directory
## Make double sure, that OpenMSConfig.cmake is found
SET(INITIAL_CACHE "${INITIAL_CACHE}
  OpenMS_DIR:PATH=${CTEST_BINARY_DIRECTORY}
  CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
  OPENMS_CONTRIB_LIBS=${OPENMS_CONTRIB_LIBS}
")

## (re)define build name and test directories
SET (CTEST_BUILD_NAME "${CTEST_BUILD_NAME}_External")
SET (CTEST_SOURCE_DIRECTORY ${CTEST_SOURCE_TESTEXTERNAL_DIRECTORY})
SET (CTEST_BINARY_DIRECTORY ${CTEST_BINARY_TESTEXTERNAL_DIRECTORY})

## From here on, CTEST_BINARY_DIRECTORY changes!
SET (CTEST_PROJECT_NAME "OpenMS_external_code_test")

## Not sure why this was needed. It actually fails most of the time. With clean checkouts I think this is not needed.
## CTEST_EMPTY_BINARY_DIRECTORY (${CTEST_BINARY_DIRECTORY})

FILE(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${INITIAL_CACHE})

CTEST_START (${DASHBOARD_MODEL} TRACK ExternalCode)

# In version 3.1.0, CTEST_UPDATE_VERSION_ONLY was introduced.
# With this we can use the Jenkins Git plugin for the checkout and only get the version for CDash 
# Otherwise skip update completely
## if(NOT "${CMAKE_VERSION}" VERSION_LESS 3.1.0)
##  SET(CTEST_UPDATE_VERSION_ONLY On)
##  CTEST_UPDATE(SOURCE "${CTEST_SOURCE_DIRECTORY}")
## endif()

string(JOIN ";" CPP_JOIN ${CMAKE_PREFIX_PATH})
string(REPLACE ";" "\\\\\\;" CPP_REP "${CPP_JOIN}")
set(MYOPTIONS
 -DCMAKE_PREFIX_PATH=${CPP_REP}
 -DOPENMS_CONTRIB_LIBS=${OPENMS_CONTRIB_LIBS}
)
message(${MYOPTIONS})
message("${MYOPTIONS}")
CTEST_CONFIGURE (BUILD "${CTEST_BINARY_TESTEXTERNAL_DIRECTORY}" OPTIONS "${MYOPTIONS}" RETURN_VALUE _ext_config_ret_val)
CTEST_BUILD     (BUILD "${CTEST_BINARY_TESTEXTERNAL_DIRECTORY}" NUMBER_ERRORS _ext_build_errors)
CTEST_TEST      (BUILD "${CTEST_BINARY_TESTEXTERNAL_DIRECTORY}")
if(CDASH_SUBMIT)
  CTEST_SUBMIT    (PARTS Configure Build Test)
endif()

restore_variables(required_variables)

# indicate errors during build (do not show up in test results)
if(${_ext_build_errors} GREATER 0 OR NOT ${_ext_config_ret_val} EQUAL 0)
  file(WRITE "${CTEST_BINARY_DIRECTORY}/external_build_failed" "external_build_failed")
endif()
## Cannot use global macro. We want to copy the results to the main build dir.
safe_message("Backing up test results. Adding prefix External.")
file(COPY ${CTEST_BINARY_TESTEXTERNAL_DIRECTORY}/Testing DESTINATION ${CTEST_BINARY_DIRECTORY}/External_Testing)
