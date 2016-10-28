# checker.cmake
# Author: Stephan Aiche
# Date:   01/03/2011
# BRIEF:  This script will execute the checker who reports its errors in a 
#         cdash compliant way. Afterwards it will submit the results to the
#         nightly build server

# Check for required variables.
set(required_variables "CTEST_SOURCE_DIRECTORY;CTEST_BINARY_DIRECTORY;CTEST_BUILD_NAME")
backup_and_check_variables(required_variables)

if(NOT DEFINED CDASH_SUBMIT)
    set(CDASH_SUBMIT Off)
endif()

SET (CTEST_BUILD_NAME "${CTEST_BUILD_NAME}_Checker")

# now we hack our own checker into cdash
# we assume here that all tests have been build/run already
MACRO (CTEST_CHECKER)
  set(CHECKER_LOG "${CTEST_BINARY_DIRECTORY}/checker.log")
  safe_message("Starting checker with log in ${CHECKER_LOG}")
  
  execute_process(
    COMMAND ${PHP_EXECUTABLE} ${CTEST_SOURCE_DIRECTORY}/tools/checker.php ${CTEST_SOURCE_DIRECTORY} ${CTEST_BINARY_DIRECTORY} -r
    OUTPUT_FILE ${CHECKER_LOG}
    WORKING_DIRECTORY ${CTEST_SOURCE_DIRECTORY}
  )
 
  safe_message("Finished checker with log in ${CHECKER_LOG}")
ENDMACRO(CTEST_CHECKER)

# test again and execute checker on track/group Checker
CTEST_START     (${DASHBOARD_MODEL} TRACK Checker)
# In version 3.1.0, CTEST_UPDATE_VERSION_ONLY was introduced.
# With this we can use the Jenkins Git plugin for the checkout and only get the version for CDash 
# Otherwise skip update completely
if(NOT "${CMAKE_VERSION}" VERSION_LESS 3.1.0)
 SET(CTEST_UPDATE_VERSION_ONLY On)
 CTEST_UPDATE(SOURCE "${CTEST_SOURCE_DIRECTORY}")
endif()
CTEST_TEST      (BUILD "${CTEST_BINARY_DIRECTORY}")
CTEST_CHECKER   ()
if(CDASH_SUBMIT)
  CTEST_SUBMIT    (PARTS Configure Build Test)
endif()

restore_variables(required_variables)
