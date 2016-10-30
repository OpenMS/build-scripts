### TODO rework to make it more generic (e.g. on bundle name etc.)

# Check for required variables.
## TODO THIRDPARTY_ROOT could theoretically be made optional. Ships without thirdparty then.
set(required_variables "CTEST_SOURCE_DIRECTORY;CTEST_BINARY_DIRECTORY;INITIAL_CACHE;CTEST_BUILD_NAME")

backup_and_check_variables(required_variables)

if(NOT DEFINED CDASH_SUBMIT)
    set(CDASH_SUBMIT Off)
endif()

if(NOT DEFINED DASHBOARD_MODEL)
    set(DASHBOARD_MODEL Experimental)
endif()


SET (CTEST_BUILD_NAME "${CTEST_BUILD_NAME}_KNIME")

# build the package and submit the results to cdash  
CTEST_START   (${DASHBOARD_MODEL} TRACK KNIME)

# In version 3.1.0, CTEST_UPDATE_VERSION_ONLY was introduced.
# With this we can use the Jenkins Git plugin for the checkout and only get the version for CDash 
# Otherwise skip update completely
if(NOT "${CMAKE_VERSION}" VERSION_LESS 3.1.0)
 SET(CTEST_UPDATE_VERSION_ONLY On)
 CTEST_UPDATE (SOURCE "${CTEST_SOURCE_DIRECTORY}")
endif()

CTEST_CONFIGURE(OPTIONS "-DENABLE_PREPARE_KNIME_PACKAGE=On;-DSEARCH_ENGINES_DIRECTORY=$ENV{SEARCH_ENGINES_DIRECTORY}" RETURN_VALUE RECONFIGURE_FOR_PACKAGE_BUILD)
  
if( NOT RECONFIGURE_FOR_PACKAGE_BUILD EQUAL 0)
	message("Could not reconfigure ${CTEST_BINARY_DIRECTORY} for KNIME build")
	message(FATAL_ERROR "Reconfigure resulted in: ERROR LEVEL ${RECONFIGURE_FOR_PACKAGE_BUILD}")
endif()

CTEST_BUILD   (TARGET prepare_knime_package)

if(CDASH_SUBMIT)
  CTEST_SUBMIT(PARTS Build)
endif()

restore_variables(required_variables)
