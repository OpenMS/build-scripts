### TODO rework to make it more generic (e.g. on bundle name etc.)

# Check for required variables.
## TODO THIRDPARTY_ROOT could theoretically be made optional. Ships without thirdparty then.
set(required_variables "CTEST_SOURCE_DIRECTORY;CTEST_BINARY_DIRECTORY;INITIAL_CACHE;CTEST_BUILD_NAME;THIRDPARTY_ROOT")

backup_and_check_variables(required_variables)

if(NOT DEFINED CDASH_SUBMIT)
    set(CDASH_SUBMIT Off)
endif()

SET (CTEST_BUILD_NAME "${CTEST_BUILD_NAME}_KNIME")

safe_message("Executing ${CMAKE_COMMAND} -DENABLE_PREPARE_KNIME_PACKAGE=On -DSEARCH_ENGINES_DIRECTORY=${THIRDPARTY_ROOT} ${CTEST_SOURCE_DIRECTORY}")
safe_message("Working directory is ${CTEST_BINARY_DIRECTORY}")

execute_process(
	COMMAND ${CMAKE_COMMAND} -DENABLE_PREPARE_KNIME_PACKAGE=On -DSEARCH_ENGINES_DIRECTORY=${THIRDPARTY_ROOT} ${CTEST_SOURCE_DIRECTORY}
	WORKING_DIRECTORY "${CTEST_BINARY_DIRECTORY}/"
	RESULT_VARIABLE RECONFIGURE_FOR_PACKAGE_BUILD
	OUTPUT_VARIABLE RECONFIGURE_FOR_PACKAGE_BUILD_OUT
	ERROR_VARIABLE RECONFIGURE_FOR_PACKAGE_BUILD_OUT  
)
  
if( NOT RECONFIGURE_FOR_PACKAGE_BUILD EQUAL 0)
	message("Could not reconfigure ${CTEST_BINARY_DIRECTORY} for KNIME build")
	message(FATAL_ERROR "reconfigure resulted in: ${RECONFIGURE_FOR_PACKAGE_BUILD}")
endif()

## TODO not sure if needed
SET( $ENV{PATH} "${CTEST_BINARY_DIRECTORY}/bin:$ENV{PATH}" )


# build the package and submit the results to cdash  
CTEST_START   (Nightly TRACK KNIME)
# In version 3.1.0, CTEST_UPDATE_VERSION_ONLY was introduced.
# With this we can use the Jenkins Git plugin for the checkout and only get the version for CDash 
# Otherwise skip update completely
if(NOT "${CMAKE_VERSION}" VERSION_LESS 3.1.0)
 SET(CTEST_UPDATE_VERSION_ONLY On)
 CTEST_UPDATE (SOURCE "${CTEST_SOURCE_DIRECTORY}")
endif()

CTEST_BUILD   (TARGET prepare_knime_package)

if(CDASH_SUBMIT)
  CTEST_SUBMIT(PARTS Build)
endif()


### TODO use RSYNC for putting on FTP or do it completely outside of CMake.
# copy KNIME plugin to destination
#file(
#		COPY ${CTEST_BINARY_DIRECTORY}/ctds/
#		DESTINATION ${TARGET_PATH}
#)

restore_variables(required_variables)