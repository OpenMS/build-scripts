## CMake Nightly Build Scripts for Windows
## (c) 2013 Stephan Aiche

# construct the build name from platform settings
set (CTEST_BUILD_NAME "${OPENMS_BUILDNAME_PREFIX}${SYSTEM_IDENTIFIER}-${compiler_prefix}-${BUILD_TYPE}")

# set variables describing the build environments
set (CTEST_BINARY_DIRECTORY "${BUILD_DIRECTORY}/${CTEST_BUILD_NAME}")
set(required_variables "SCRIPT_PATH;CTEST_SOURCE_DIRECTORY;CTEST_GIT_COMMAND;CTEST_UPDATE_COMMAND")

check_variables(required_variables)

# 
#set (CTEST_COMMAND "${CTEST_COMMAND} -D Nightly -C ${BUILD_TYPE}")

# intialize variables with Off that are not directly required
set (not_required "TEST_COVERAGE;RUN_CHECKER;BUILD_DOCU;RERUN")
if(NOT DEFINED ${var})
  set(${var} Off)
endif()

#check requirements for coverage build
if(TEST_COVERAGE)
  if(NOT DEFINED CTEST_COVERAGE_COMMAND)
    safe_message(FATAL_ERROR "CTEST_COVERAGE_COMMAND needs to be set for coverage builds")
  endif()
endif()

set (CTEST_BINARY_TEST_DIRECTORY "${CTEST_BINARY_DIRECTORY}/source/TEST/")

if(NOT RERUN)
  # clear the binary directory to avoid problems
  ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})
endif(NOT RERUN)

set (CTEST_CMAKE_GENERATOR "${GENERATOR}" )
set (CTEST_BUILD_CONFIGURATION ${BUILD_TYPE})

# ensure the config is known to ctest
set(CTEST_COMMAND "${CTEST_COMMAND} -D Nightly -C ${BUILD_TYPE} ")

# setup the environment variables for windows
set ( CTEST_ENVIRONMENT
	"PATH=${QT}/bin\;${CONTRIB}/lib\;${CTEST_BINARY_DIRECTORY}/bin/${BUILD_TYPE}\;${MYRIMATCH_PATH}\;${OMSSA_PATH}\;${XTANDEM_PATH}\;$ENV{PATH}"
	"Path=${QT}/bin\;${CONTRIB}/lib\;${CTEST_BINARY_DIRECTORY}/bin/${BUILD_TYPE}\;${MYRIMATCH_PATH}\;${OMSSA_PATH}\;${XTANDEM_PATH}\;$ENV{Path}")
set (ENV{PATH} "${QT}/bin\;${CONTRIB}/lib\;${CTEST_BINARY_DIRECTORY}/bin/${BUILD_TYPE}\;${MYRIMATCH_PATH}\;${OMSSA_PATH}\;${XTANDEM_PATH}\;$ENV{PATH}")
set (ENV{Path} "${QT}/bin\;${CONTRIB}/lib\;${CTEST_BINARY_DIRECTORY}/bin/${BUILD_TYPE}\;${MYRIMATCH_PATH}\;${OMSSA_PATH}\;${XTANDEM_PATH}\;$ENV{Path}")	
	
set(INITIAL_CACHE "
CMAKE_PREFIX_PATH:PATH=${CONTRIB}
CMAKE_BUILD_TYPE:STRING=${BUILD_TYPE}
CMAKE_GENERATOR:INTERNAL=${GENERATOR}
QT_QMAKE_EXECUTABLE:FILEPATH=${QT}/bin/qmake.exe
ENABLE_UNITYBUILD=On
")

if(NOT RERUN)
  # this is the initial cache to use for the binary tree, be careful to escape
  # any quotes inside of this string if you use it
  file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${INITIAL_CACHE})
endif(NOT RERUN)

# ------------------------------------------------------------
# Increase number of reported errors/warnings.
# ------------------------------------------------------------

## customize reporting of errors in CDash
set(CTEST_CUSTOM_MAXIMUM_NUMBER_OF_ERRORS 10000)
set(CTEST_CUSTOM_MAXIMUM_NUMBER_OF_WARNINGS 10000)

# ------------------------------------------------------------
# Suppress certain warnings.
# ------------------------------------------------------------

# Of course, the following list should be kept as short as possible and should
# be limited to very small lists of system/compiler pairs.  However, some
# warnings cannot be suppressed from the source.  Also, the warnings
# suppressed here should be specific to certain system/compiler versions.
#
# If you add anything then document what it does.

set (CTEST_CUSTOM_WARNING_EXCEPTION
    # Suppress warnings imported from boost
    ".include/boost.*:.*"
    ".*boost_static_assert_typedef_575.*"
    ".*boost_static_assert_typedef_628.*"
    "*BOOST_STATIC_ASSERT*")


# start virtual xserver (Xvnc) to test TOPPView
# TODO: we need to find a way to kill the X-Server directly from the script
#START_XSERVER(DISPLAY)
#message(STATUS "Started X-Server on ${DISPLAY}")

# do the dashboard/testings steps
ctest_start (Nightly)

if(NOT RERUN)
  ctest_update (SOURCE "${CTEST_SOURCE_DIRECTORY}")
  ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
	set(CTEST_PROJECT_NAME "OpenMS_host")
  ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}" APPEND)
	set(CTEST_PROJECT_NAME "OpenMS")
endif(NOT RERUN)

# reset project name 
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 3)

if(TEST_COVERAGE)
  ctest_coverage(BUILD "${CTEST_BINARY_DIRECTORY}")
endif(TEST_COVERAGE)

## submit results to cdash
ctest_submit()

if(EXTERNAL_CODE_TESTS)
  include ( "${SCRIPT_PATH}/external_code.cmake" )
endif(EXTERNAL_CODE_TESTS)

#if(NOT KEEP_BUILD AND NOT RERUN)
#  CTEST_EMPTY_BINARY_DIRECTORY (${CTEST_BINARY_DIRECTORY})
#endif()
