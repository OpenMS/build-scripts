## Check for all required variables that have to be set in the main script and raise errors
set(required_variables "OPENMS_BUILDNAME_PREFIX;SYSTEM_IDENTIFIER;COMPILER_IDENTIFIER;SCRIPT_PATH;CTEST_SOURCE_DIRECTORY;CTEST_GIT_COMMAND;MAKE_COMMAND;CONTRIB;BUILD_TYPE;QT_QMAKE_BIN_PATH;GENERATOR")

foreach(var IN LISTS required_variables)
  if(NOT DEFINED ${var})
    safe_message(FATAL_ERROR "Variable <${var}> needs to be set to run this script")
  endif()
endforeach()

## Set non-required boolean variables to "Off" if not present
set (not_required "PACKAGE_TEST;EXTERNAL_CODE_TESTS;TEST_COVERAGE;TEST_STYLE;BUILD_PYOPENMS;RUN_CHECKER;RUN_PYTHON_CHECKER;BUILD_DOCU;RERUN")

foreach(var IN LISTS not_required)
  if(NOT DEFINED ${var})
    set(${var} Off)
  endif()
endforeach()

## Compiler identifier is e.g. VS10_x64 or gcc4.9 or clang3.3
SET (CTEST_BUILD_NAME "${OPENMS_BUILDNAME_PREFIX}-${SYSTEM_IDENTIFIER}-${COMPILER_IDENTIFIER}-${BUILD_TYPE}")

## check requirements for special CTest features (style/coverage) and append additional information to the build name
## TODO Does it require GCC as compiler? If so, test here.
if(TEST_COVERAGE)
  if(NOT DEFINED CTEST_COVERAGE_COMMAND)
    safe_message(FATAL_ERROR "CTEST_COVERAGE_COMMAND needs to be set for coverage builds")
  endif()
  if(NOT BUILD_TYPE STREQUAL Debug)
    safe_message(FATAL_ERROR "For coverage check, the library should be built in Debug mode with Debug symbols.")
  endif()
  set(CTEST_BUILD_NAME "${CTEST_BUILD_NAME}-Coverage")
elseif(TEST_STYLE)
  set(CTEST_BUILD_NAME "${CTEST_BUILD_NAME}-Style")
endif()



# set variables describing the build environments (with Jenkins I assume we do not need to mark the dir with the name)
#SET (CTEST_BINARY_DIRECTORY "${BUILD_DIRECTORY}/${CTEST_BUILD_NAME}")
SET (CTEST_BINARY_DIRECTORY "${BUILD_DIRECTORY}")

SET (CTEST_BINARY_TEST_DIRECTORY "${CTEST_BINARY_DIRECTORY}/source/TEST/")

set (CTEST_CMAKE_GENERATOR "${GENERATOR}" )
set (CTEST_BUILD_CONFIGURATION ${BUILD_TYPE})

# Add binary dir to Windows path for the tests
if(WIN32)
	set ( CTEST_ENVIRONMENT "PATH=${CTEST_BINARY_DIRECTORY}/bin/${BUILD_TYPE}\;$ENV{PATH}" "Path=${CTEST_BINARY_DIRECTORY}/bin/${BUILD_TYPE}\;$ENV{Path}")
	set (ENV{PATH} "${CTEST_BINARY_DIRECTORY}/bin/${BUILD_TYPE}\;$ENV{PATH}")
	set (ENV{Path} "${CTEST_BINARY_DIRECTORY}/bin/${BUILD_TYPE}\;$ENV{Path}")
else(WIN32)
	# customizing PATH so ExecutePipeline_test finds its executables
	set(ENV{PATH} "${CTEST_BINARY_DIRECTORY}/bin:$ENV{PATH}")
endif()

# ensure the config is known to ctest
set(CTEST_COMMAND "${CTEST_COMMAND} -D Nightly -C ${BUILD_TYPE} ")

SET(INITIAL_CACHE "
CMAKE_PREFIX_PATH:PATH=${CONTRIB}
CMAKE_BUILD_TYPE:STRING=${BUILD_TYPE}
CMAKE_GENERATOR:INTERNAL=${GENERATOR}
QT_QMAKE_EXECUTABLE:FILEPATH=${QT_QMAKE_BIN_PATH}qmake
MAKECOMMAND:STRING=${MAKE_COMMAND} -i -j4
")

## On win, we use unity builds
## On unixes, we try not to link boost statically (mostly because of OSX)
if(WIN32)
  SET(INITIAL_CACHE "${INITIAL_CACHE}
    ENABLE_UNITYBUILD=On
  " )
else(WIN32)
  SET(INITIAL_CACHE "${INITIAL_CACHE}
    BOOST_USE_STATIC=OFF
  " )
endif(WIN32)

## Docu needs latex (TODO But this should be automatically found????)
# if(BUILD_DOCU)
#   if(NOT DEFINED ${LATEX})
#     safe_message(FATAL_ERROR "Variable <LATEX_COMPILER> needs to be set to run this script")
#   endif()
#   if(NOT DEFINED ${PDFLATEX})
#     safe_message(FATAL_ERROR "Variable <PDFLATEX_COMPILER> needs to be set to run this script")
#   endif()
  
#   SET(INITIAL_CACHE "${INITIAL_CACHE}
#     ## standard /usr/texbin/pdflatex
#     LATEX_COMPILER:FILEPATH=${LATEX}
#     PDFLATEX_COMPILER:FILEPATH=${PDFLATEX}
#   " )
# endif()

## If you set a custom compiler, pass it to the CMake calls
if(DEFINED ${C_COMPILER})
  SET(INITIAL_CACHE "${INITIAL_CACHE}
CMAKE_C_COMPILER:FILEPATH=${C_COMPILER}
CMAKE_CXX_COMPILER:FILEPATH=${CXX_COMPILER}
  " )
endif(DEFINED ${C_COMPILER})


## TODO does this add these flag or replace all flags?

##Error(s) while accumulating results:
##  Problem reading source file: /home/jenkins/workspace/openms_linux/025a6a2d/source/src/openms/include/OpenMS/DATASTRUCTURES/Map.h line:166  out total: 191
## Fixed in 2.8.7
if(TEST_COVERAGE)
  SET(INITIAL_CACHE "${INITIAL_CACHE}
CMAKE_C_FLAGS:STRING=-fprofile-arcs -ftest-coverage
CMAKE_CXX_FLAGS:STRING=-fprofile-arcs -ftest-coverage
CMAKE_EXE_LINKER_FLAGS:STRING=-fprofile-arcs -ftest-coverage
CMAKE_MODULE_LINKER_FLAGS:STRING=-fprofile-arcs -ftest-coverage
CMAKE_SHARED_LINKER_FLAGS:STRING=-fprofile-arcs -ftest-coverage
" )
endif(TEST_COVERAGE)

if(TEST_STYLE)
	set(INITIAL_CACHE "${INITIAL_CACHE} ENABLE_STYLE_TESTING:BOOL=On")
endif()

## Please specify the deployment target yourself, if you want to build OpenMS backwards compatible.
#if(APPLE)
## if you want to use another SDK add the following also to the cache (usually not necessary)
## CMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.8.sdk/
## Anyway, we try to build relatively backwards compatible (10.6)
#  SET(INITIAL_CACHE "${INITIAL_CACHE}
#    CMAKE_OSX_DEPLOYMENT_TARGET=10.6
#  ")
#endif()
  
# customize errors
file(COPY "${SCRIPT_PATH}/CTestCustom.cmake" DESTINATION ${CTEST_BINARY_DIRECTORY})

## Please start an XServer yourself, if you wan to test TOPPView.
# if(UNIX)
#   # start virtual xserver (Xvnc) to test TOPPView
#   START_XSERVER(DISPLAY)
#   message(STATUS "Started X-Server on ${DISPLAY}")
# endif(UNIX)

if(BUILD_PYOPENMS)
	set(INITIAL_CACHE "${INITIAL_CACHE}
          PYOPENMS=ON")

	# http://stackoverflow.com/questions/22313407/clang-error-unknown-argument-mno-fused-madd-python-package-installation-fa
	#export CFLAGS=-Qunused-arguments
	#export CPPFLAGS=-Qunused-arguments

	set(ENV{CFLAGS} "-Qunused-arguments")
	set(ENV{CPPFLAGS} "-Qunused-arguments")
endif()

# this is the initial cache to use for the binary tree, be careful to escape
# any quotes inside of this string if you use it
FILE(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${INITIAL_CACHE})

# do the dashboard/testings steps
# TODO make a variable out of it? E.g. MODEL
ctest_start  (Nightly)

ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")

# Reads the previously copied CTestCustom.cmake (which e.g. contains excluded warnings)
ctest_read_custom_files("${CTEST_BINARY_DIRECTORY}")

if(WIN32)
  # So that windows uses the correct sln file
  set(CTEST_PROJECT_NAME "OpenMS_host")
endif(WIN32)

ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")

if(WIN32)
  # Reset project
  set(CTEST_PROJECT_NAME "OpenMS")
endif(WIN32)

# If we only tested style, the binaries were not built -> no testing
if(NOT TEST_STYLE)
	ctest_test(BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 2)
	if(BUILD_PYOPENMS)
		ctest_build(BUILD "${CTEST_BINARY_DIRECTORY}" TARGET pyopenms APPEND)
	endif()
	# adapt project name to allow xcode to find the test project
endif()

# E.g. for use with Jenkins or other Dashboards
if (CDASH_SUBMIT)
  ctest_submit() #(RETRY_COUNT 3)
endif()

if(TEST_COVERAGE)
  ctest_coverage(BUILD "${CTEST_BINARY_DIRECTORY}")
  	if(CDASH_SUBMIT)
	  ctest_submit(PARTS Coverage)
	endif()
endif()

if(RUN_CHECKER)
  include ( "${SCRIPT_PATH}/checker.cmake" )
endif(RUN_CHECKER)

if(RUN_PYTHON_CHECKER)
	include("${SCRIPT_PATH}/python_checker.cmake")
endif()

if(BUILD_DOCU)
  safe_message(STATUS "Enter build docu")
  include ( "${SCRIPT_PATH}/docu.cmake" )
endif(BUILD_DOCU)

if(EXTERNAL_CODE_TESTS)
  include ( "${SCRIPT_PATH}/external_code.cmake" )
endif(EXTERNAL_CODE_TESTS)

if(PACKAGE_TEST)
  include ( "${SCRIPT_PATH}/package_test.cmake" )
endif(PACKAGE_TEST)

#if(NOT KEEP_BUILD AND NOT RERUN)
#  ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})
#endif(NOT KEEP_BUILD AND NOT RERUN)
