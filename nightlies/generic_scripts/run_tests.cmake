SET (CTEST_BUILD_NAME "${OPENMS_BUILDNAME_PREFIX}${SYSTEM_IDENTIFIER}-${COMPILER_IDENTIFIER}-${BUILD_TYPE}")

## append additional information to the build name
if(TEST_COVERAGE)
  set(CTEST_BUILD_NAME "${CTEST_BUILD_NAME}-Coverage")
endif(TEST_COVERAGE)

# set variables describing the build environments
SET (CTEST_BINARY_DIRECTORY "${BUILD_DIRECTORY}/${CTEST_BUILD_NAME}")
set(required_variables "PACKAGE_TEST;EXTERNAL_CODE_TESTS;SCRIPT_PATH;CTEST_SOURCE_DIRECTORY;CXX_COMPILER;C_COMPILER;CTEST_GIT_COMMAND;MAKE_COMMAND;CTEST_BINARY_DIRECTORY;OPENMS_CONTRIB;BUILD_TYPE;QT_QMAKE;GENERATOR")


foreach(var IN LISTS required_variables)
  if(NOT DEFINED ${var})
    safe_message(FATAL_ERROR "Variable <${var}> needs to be set to run this script")
  endif()
endforeach()

set (not_required "TEST_COVERAGE;RUN_CHECKER;BUILD_DOCU;RERUN")
foreach(var IN LISTS not_required)
  if(NOT DEFINED ${var})
    set(${var} Off)
  endif()
endforeach(var IN LISTS required_variables)

if(RERUN)
  ## DISTINGUISH MULTIPLE BUILDS in CDASH
  string(RANDOM RANDOM_BUILD_SUFFIX)
  SET(CTEST_BUILD_NAME "${CTEST_BUILD_NAME}-${RANDOM_BUILD_SUFFIX}")
endif(RERUN)

#check requirements for coverage build
if(TEST_COVERAGE)
  if(NOT DEFINED CTEST_COVERAGE_COMMAND)
    safe_message(FATAL_ERROR "CTEST_COVERAGE_COMMAND needs to be set for coverage builds")
  endif()
endif()

SET (CTEST_BINARY_TEST_DIRECTORY "${CTEST_BINARY_DIRECTORY}/source/TEST/")

if(NOT RERUN)
  # clear the binary directory to avoid problems
  CTEST_EMPTY_BINARY_DIRECTORY (${CTEST_BINARY_DIRECTORY})
endif(NOT RERUN)

SET(INITIAL_CACHE "
CMAKE_FIND_ROOT_PATH:PATH=${OPENMS_CONTRIB}
CMAKE_BUILD_TYPE:STRING=${BUILD_TYPE}
CMAKE_GENERATOR:INTERNAL=${GENERATOR}
QT_QMAKE_EXECUTABLE:FILEPATH=${QT_QMAKE}
CMAKE_C_COMPILER:FILEPATH=${C_COMPILER}
CMAKE_CXX_COMPILER:FILEPATH=${CXX_COMPILER}
MAKECOMMAND:STRING=${MAKE_COMMAND} -i -j4
")

if(TEST_COVERAGE)
  SET(INITIAL_CACHE "${INITIAL_CACHE}
CMAKE_C_FLAGS:STRING=-fprofile-arcs -ftest-coverage
CMAKE_CXX_FLAGS:STRING=-fprofile-arcs -ftest-coverage
CMAKE_EXE_LINKER_FLAGS:STRING=-fprofile-arcs -ftest-coverage
CMAKE_MODULE_LINKER_FLAGS:STRING=-fprofile-arcs -ftest-coverage
CMAKE_SHARED_LINKER_FLAGS:STRING=-fprofile-arcs -ftest-coverage
" )
endif(TEST_COVERAGE)

# ------------------------------------------------------------
# Increase number of reported errors/warnings.
# ------------------------------------------------------------

## customize reporting of errors in CDash
set(CTEST_CUSTOM_MAXIMUM_NUMBER_OF_ERRORS 1000)
set(CTEST_CUSTOM_MAXIMUM_NUMBER_OF_WARNINGS 1000)

# ------------------------------------------------------------
# Find git and checkout if necessary
# -----------------------------------------------------------

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
    "*BOOST_STATIC_ASSERT*"
    # Suppress warnings imported from seqan
    ".include/seqan.*:.*"
    ".*seqan.*[-Wunused-local-typedefs]"
		".*qsharedpointer_impl.h:595:43.*"
    )


if(NOT RERUN)
  # this is the initial cache to use for the binary tree, be careful to escape
  # any quotes inside of this string if you use it
  FILE(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${INITIAL_CACHE})
endif(NOT RERUN)

# customizing PATH so ExecutePipeline_test finds its executables
set(ENV{PATH} "${CTEST_BINARY_DIRECTORY}/bin:$ENV{PATH}")


if(UNIX)
  # start virtual xserver (Xvnc) to test TOPPView
  START_XSERVER(DISPLAY)
  message(STATUS "Started X-Server on ${DISPLAY}")
endif(UNIX)

# do the dashboard/testings steps
ctest_start  (Nightly)

# TODO Do we need update if Jenkins does the pulling for us?
if(NOT RERUN)
	ctest_update (SOURCE "${CTEST_SOURCE_DIRECTORY}")
	ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
  ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
endif(NOT RERUN)

ctest_test(BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_submit() #(RETRY_COUNT 3)

if(TEST_COVERAGE)
  ctest_coverage(BUILD "${CTEST_BINARY_DIRECTORY}")
	ctest_submit(PARTS Coverage)
endif()

if(RUN_CHECKER)
  include ( "${SCRIPT_PATH}/checker.cmake" )
endif(RUN_CHECKER)

safe_message(STATUS "Enter build docu")
if(BUILD_DOCU)
  include ( "${SCRIPT_PATH}/docu.cmake" )
endif(BUILD_DOCU)

if(EXTERNAL_CODE_TESTS)
  include ( "${SCRIPT_PATH}/external_code.cmake" )
endif(EXTERNAL_CODE_TESTS)

if(PACKAGE_TEST)
  include ( "${SCRIPT_PATH}/package_test.cmake" )
endif(PACKAGE_TEST)

if(NOT KEEP_BUILD AND NOT RERUN)
  ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})
endif(NOT KEEP_BUILD AND NOT RERUN)
