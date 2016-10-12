### TODO rework to make it more generic (e.g. on bundle name etc.)

##TODO Check for not Windows.
# Check for required variables.
## TODO THIRDPARTY_ROOT could theoretically be made optional. Ships without thirdparty then.
set(required_variables "CTEST_SOURCE_DIRECTORY;CTEST_BINARY_DIRECTORY;INITIAL_CACHE;CTEST_BUILD_NAME;THIRDPARTY_ROOT")

backup_and_check_variables(required_variables)

if(NOT DEFINED CDASH_SUBMIT)
    set(CDASH_SUBMIT Off)
endif()

SET (CTEST_BUILD_NAME "${CTEST_BUILD_NAME}_Package")

# update the source tree

## TODO not sure why the LATEX options are needed. Should be found automatically.
if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin") 
	safe_message("Executing ${CMAKE_COMMAND} -DPACKAGE_TYPE=dmg -DLATEX_COMPILER:FILEPATH=/usr/texbin/latex -DPDFLATEX_COMPILER:FILEPATH=/usr/texbin/pdflatex -DSEARCH_ENGINES_DIRECTORY=${THIRDPARTY_ROOT} ${CTEST_SOURCE_DIRECTORY}")
	safe_message("Working directory is ${CTEST_BINARY_DIRECTORY}")

	execute_process(
	COMMAND ${CMAKE_COMMAND} -DPACKAGE_TYPE=dmg -DLATEX_COMPILER:FILEPATH=/usr/texbin/latex -DPDFLATEX_COMPILER:FILEPATH=/usr/texbin/pdflatex -DSEARCH_ENGINES_DIRECTORY=${THIRDPARTY_ROOT} ${CTEST_SOURCE_DIRECTORY}
	WORKING_DIRECTORY "${CTEST_BINARY_DIRECTORY}/"
	RESULT_VARIABLE RECONFIGURE_FOR_PACKAGE_BUILD
	OUTPUT_VARIABLE RECONFIGURE_FOR_PACKAGE_BUILD_OUT
	ERROR_VARIABLE RECONFIGURE_FOR_PACKAGE_BUILD_OUT  
	)
else()
	if(EXISTS "/etc/debian_version")
	   set ( MY_PACK_TYPE "deb")
	endif(EXISTS "/etc/debian_version")

	if(EXISTS "/etc/redhat-release")
	   set ( MY_PACK_TYPE "rpm")
	endif(EXISTS "/etc/redhat-release")
	
	safe_message("Executing ${CMAKE_COMMAND} -DPACKAGE_TYPE=${MY_PACK_TYPE} -DLATEX_COMPILER:FILEPATH=/usr/texbin/latex -DPDFLATEX_COMPILER:FILEPATH=/usr/texbin/pdflatex -DSEARCH_ENGINES_DIRECTORY=${THIRDPARTY_ROOT} ${CTEST_SOURCE_DIRECTORY}")
	safe_message("Working directory is ${CTEST_BINARY_DIRECTORY}")
	## TODO If at all, then this only works for creating Debian packages. Needs testing.
	execute_process(
		COMMAND ${CMAKE_COMMAND} -DPACKAGE_TYPE=${MY_PACK_TYPE} -DLATEX_COMPILER:FILEPATH=/usr/bin/latex -DPDFLATEX_COMPILER:FILEPATH=/usr/bin/pdflatex -DSEARCH_ENGINES_DIRECTORY=${THIRDPARTY_ROOT} ${CTEST_SOURCE_DIRECTORY}
		WORKING_DIRECTORY "${CTEST_BINARY_DIRECTORY}/"
		RESULT_VARIABLE RECONFIGURE_FOR_PACKAGE_BUILD
		OUTPUT_VARIABLE RECONFIGURE_FOR_PACKAGE_BUILD_OUT
		ERROR_VARIABLE RECONFIGURE_FOR_PACKAGE_BUILD_OUT  
	)
endif()

  
if( NOT RECONFIGURE_FOR_PACKAGE_BUILD EQUAL 0)
	message("Could not reconfigure ${CTEST_BINARY_DIRECTORY} for package build")
	message(FATAL_ERROR "reconfigure resulted in: ${RECONFIGURE_FOR_PACKAGE_BUILD}")
endif()

SET( $ENV{PATH} "${CTEST_BINARY_DIRECTORY}/bin:$ENV{PATH}" )

# build the package and submit the results to cdash  
CTEST_START   (Nightly TRACK Package)
# In version 3.1.0, CTEST_UPDATE_VERSION_ONLY was introduced.
# With this we can use the Jenkins Git plugin for the checkout and only get the version for CDash 
# Otherwise skip update completely
if(NOT "${CMAKE_VERSION}" VERSION_LESS 3.1.0)
 SET(CTEST_UPDATE_VERSION_ONLY On)
 CTEST_UPDATE(SOURCE "${CTEST_SOURCE_DIRECTORY}")
endif()

CTEST_BUILD   (TARGET doc)
CTEST_BUILD   (TARGET doc_tutorials APPEND)
CTEST_BUILD   (TARGET package APPEND)

if(CDASH_SUBMIT)
  CTEST_SUBMIT  (PARTS Build)
endif()


### TODO use RSYNC for putting on FTP or do it completely outside of CMake.
# copy package to destination
#file(RENAME ${CTEST_BINARY_DIRECTORY}/${BUNDLE_NAME} ${CTEST_BINARY_DIRECTORY}/${TARGET_NAME})
#file(
#		COPY ${CTEST_BINARY_DIRECTORY}/${TARGET_NAME}
#		DESTINATION ${PACKAGE_TARGET_PATH}
#)

restore_variables(required_variables)
