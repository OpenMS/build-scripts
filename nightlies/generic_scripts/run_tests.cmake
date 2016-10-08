## Set non-required boolean variables to "Off" if not present
set (not_required_bool "KNIME_TEST;PACKAGE_TEST;EXTERNAL_CODE_TESTS;TEST_COVERAGE;TEST_STYLE;BUILD_PYOPENMS;RUN_CHECKER;RUN_PYTHON_CHECKER;BUILD_DOCU;RERUN")

foreach(var IN LISTS not_required_bool)
  ## if undefined or not configured:
  if(NOT DEFINED ${var} OR ${var} MATCHES "\@*\@")
    set(${var} Off)
  endif()
endforeach()

## Check for all required variables that have to be set in the main script and raise errors
set(required_variables "OPENMS_BUILDNAME_PREFIX;SYSTEM_IDENTIFIER;COMPILER_IDENTIFIER;SCRIPT_PATH;CTEST_SOURCE_DIRECTORY;CTEST_GIT_COMMAND;MAKE_COMMAND;CONTRIB;BUILD_TYPE;QT_QMAKE_BIN_PATH;GENERATOR")
if(PACKAGE_TEST)
  set(required_variables ${required_variables} "BUNDLE_NAME" "TARGET_NAME")
endif()

foreach(var IN LISTS required_variables)
  if(NOT DEFINED ${var})
    safe_message(FATAL_ERROR "Variable <${var}> needs to be set to run this script")
  endif()
endforeach()

## Unset non-required string variables if not present
set (not_required_str "OPENMS_INSTALL_DIR;NUMBER_THREADS;CTEST_COVERAGE_COMMAND;MY_JAVA_PATH;MY_LATEX_PATH;MY_DOXYGEN_PATH")

foreach(var IN LISTS not_required_str)
  if(NOT DEFINED ${var} OR ${var} MATCHES "\@*\@")
    unset(${var})
  endif()
endforeach()

## Add user paths to CMAKE_PREFIX_PATH to help in the search of libraries and programs
set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} ${CONTRIB} ${MY_JAVA_PATH} ${MY_LATEX_PATH} ${MY_DOXYGEN_PATH})

## For parallel building
if(NUMBER_THREADS)
  if(WIN32) ## and MSVC Generator
    set(CTEST_BUILD_FLAGS "/maxcpucount:${NUMBER_THREADS}")
  elseif(${GENERATOR} MATCHES "XCode") ## and Darwin
    set(CTEST_BUILD_FLAGS "-jobs" "${NUMBER_THREADS}")
  else() ## Unix and Makefiles
    set(CTEST_BUILD_FLAGS "-j${NUMBER_THREADS}")
  endif()
else()
  # not defined. Set to serial for further usage.
  # TODO we could infer max number of processors
  set(NUMBER_THREADS "1")
endif()

## Compiler identifier is e.g. MSVC10x64 or gcc4.9 or clang3.3
SET (CTEST_BUILD_NAME "${OPENMS_BUILDNAME_PREFIX}-${SYSTEM_IDENTIFIER}-${COMPILER_IDENTIFIER}-${BUILD_TYPE}")

## Make sure pyOpenMS is build when you want to check it.
if(RUN_PYTHON_CHECKER)
  # if you want to check python, it needs to be built
  SET (BUILD_PYOPENMS On)
endif(RUN_PYTHON_CHECKER)

## check requirements for special CTest features (style/coverage) and append additional information to the build name
## TODO Requires GCC or newer Clang as compiler, maybe test here.
## TODO Think about putting these settings into own CMakes like the other options. Think about renaming to WithCoverage an StyleOnly
## To show additional/exclusive nature.
if(TEST_COVERAGE)
  set(INITIAL_CACHE "${INITIAL_CACHE}
    COVERAGE_EXTRA_FLAGS=${COVERAGE_EXTRA_FLAGS} -p
  ")
  if (NOT CTEST_COVERAGE_COMMAND)
      safe_message("Warning: Coverage tests enabled but no coverage command given: Defaulting to /usr/bin/gcov")
      set (CTEST_COVERAGE_COMMAND "/usr/bin/gcov")
  endif()
  # Holds additional excluding tests for coverage
  include( "${SCRIPT_PATH}/exclude_for_coverage.cmake" )
  if(NOT BUILD_TYPE STREQUAL Debug)
    safe_message(FATAL_ERROR "For coverage check, the library should be built in Debug mode with Debug symbols.")
  endif()
  set(CTEST_BUILD_NAME "${CTEST_BUILD_NAME}-Coverage")
elseif(TEST_STYLE)
  ## TODO requires Python executable?
  set(CTEST_BUILD_NAME "${CTEST_BUILD_NAME}-Style")
endif()

## Package dependent requirements
if(NOT THIRDPARTY_ROOT)
  if(KNIME_TEST OR PACKAGE_TEST)
    safe_message(FATAL_ERROR "Trying to build a package or KNIME plugin without setting the path to the Thirdparty binaries (THIRDPARTY_ROOT)")
  else()
    safe_message("Warning: Trying to test OpenMS without setting the path to the Thirdparty binaries (THIRDPARTY_ROOT). This will disable their tests.")
  endif()
else()
  find_package(Java COMPONENTS Runtime)
  if(NOT JAVA_FOUND)
    safe_message("Warning: Trying to test Thirdparty tools without Java. Some of them require a JRE. Please add it to the path environment variable or the CMAKE_PREFIX_PATH")
  endif()
  get_filename_component(JAVA_BIN_DIR ${Java_JAVA_EXECUTABLE} DIRECTORY)
  safe_message("Adding ${JAVA_BIN_DIR} to path for Thirdparty tests.")
  if(WIN32)
    SUBDIRLIST(SUBDIRS ${THIRDPARTY_ROOT})
    FOREACH(subdir ${SUBDIRS})
          set (CTEST_ENVIRONMENT "PATH=${THIRDPARTY_ROOT}/${subdir}\;$ENV{PATH}" "Path=${THIRDPARTY_ROOT}/${subdir}\;$ENV{Path}")
          set (ENV{PATH} "${THIRDPARTY_ROOT}/${subdir}\;$ENV{PATH}")
          set (ENV{Path} "${THIRDPARTY_ROOT}/${subdir}\;$ENV{Path}")
          safe_message("Added ${THIRDPARTY_ROOT}/${subdir} to the PATH enviroment used by CMake and CTest.")
    ENDFOREACH()
    set (CTEST_ENVIRONMENT "PATH=${JAVA_BIN_DIR}\;$ENV{PATH}" "Path=${JAVA_BIN_DIR}\;$ENV{Path}")
    set (ENV{PATH} "${JAVA_BIN_DIR}\;$ENV{PATH}")
    set (ENV{Path} "${JAVA_BIN_DIR}\;$ENV{Path}")
  else()
    # Add Search Engine test binaries to PATH, such that tests are automatically enabled.
    SUBDIRLIST(SUBDIRS ${THIRDPARTY_ROOT})
    FOREACH(subdir ${SUBDIRS})
          set (CTEST_ENVIRONMENT "PATH=${THIRDPARTY_ROOT}/${subdir}:$ENV{PATH}")
          set (ENV{PATH} "${THIRDPARTY_ROOT}/${subdir}:$ENV{PATH}")
          safe_message("Added ${THIRDPARTY_ROOT}/${subdir} to the PATH enviroment used by CMake and CTest.")
    ENDFOREACH()
    set (CTEST_ENVIRONMENT "PATH=${JAVA_BIN_DIR}:$ENV{PATH}")
    set (ENV{PATH} "${JAVA_BIN_DIR}:$ENV{PATH}")
  endif()
endif()

# set variables describing the build environments (with Jenkins I assume we do not need to mark the dir with the name)
#SET (CTEST_BINARY_DIRECTORY "${BUILD_DIRECTORY}/${CTEST_BUILD_NAME}")
SET (CTEST_BINARY_DIRECTORY "${BUILD_DIRECTORY}")

SET (CTEST_BINARY_TEST_DIRECTORY "${CTEST_BINARY_DIRECTORY}/source/TEST/")

set (CTEST_CMAKE_GENERATOR "${GENERATOR}" )
set (CTEST_BUILD_CONFIGURATION ${BUILD_TYPE})

# Setup Paths for the tests (e.g. ExecutePipeline)
if(WIN32)
  ## VS is always multiconf
  set (BINARY_DIR "${CTEST_BINARY_DIRECTORY}/bin/${BUILD_TYPE}")
  set (CTEST_ENVIRONMENT "PATH=${BINARY_DIR}\;$ENV{PATH}" "Path=${BINARY_DIR}\;$ENV{Path}")
  set (ENV{PATH} "${BINARY_DIR}\;$ENV{PATH}")
  set (ENV{Path} "${BINARY_DIR}\;$ENV{Path}")

  # Setup additional environment variables for windows
  ## TODO Why is the following only needed on Windows?
  ## Add rest (e.g. QT, CONTRIB)
  set (CTEST_ENVIRONMENT "PATH=${QT_QMAKE_BIN_PATH}\;${CONTRIB}/lib\;$ENV{PATH}" "Path=${QT_QMAKE_BIN_PATH}\;${CONTRIB}/lib\;$ENV{Path}")
  set (ENV{PATH} "${QT_QMAKE_BIN_PATH}\;${CONTRIB}/lib\;$ENV{PATH}")
  set (ENV{Path} "${QT_QMAKE_BIN_PATH}\;${CONTRIB}/lib\;$ENV{Path}")
else(WIN32)
  ## Multi config like Xcode?
  if(CMAKE_CONFIGURATION_TYPES)
    set (BINARY_DIR "${CTEST_BINARY_DIRECTORY}/bin/${BUILD_TYPE}")
  else()
    set (BINARY_DIR "${CTEST_BINARY_DIRECTORY}/bin/")
  endif()
  set (ENV{PATH} "${BINARY_DIR}:$ENV{PATH}")
endif()

# ensure the config is known to ctest
set(CTEST_COMMAND "${CTEST_COMMAND} -D Nightly -C ${BUILD_TYPE} ")

# If it was set, use custom install dir
if(OPENMS_INSTALL_DIR)
  SET(INITIAL_CACHE "${INITIAL_CACHE}
    CMAKE_INSTALL_PREFIX:PATH=${OPENMS_INSTALL_DIR}
    ")
  message("Warning: CMAKE_INSTALL_PREFIX cache variable for following CMake calls is overwritten/set to ${OPENMS_INSTALL_DIR}.")
endif()

SET(INITIAL_CACHE "${INITIAL_CACHE}
CMAKE_PREFIX_PATH:PATH=${CMAKE_PREFIX_PATH}
CMAKE_BUILD_TYPE:STRING=${BUILD_TYPE}
CMAKE_GENERATOR:INTERNAL=${GENERATOR}
QT_QMAKE_EXECUTABLE:FILEPATH=${QT_QMAKE_BIN_PATH}/qmake
MAKECOMMAND:STRING=${MAKE_COMMAND} -i -j${NUMBER_THREADS}
")

## On win, we use unity builds
## On unixes, we try not to link boost statically (mostly because of OSX)
if(WIN32)
  SET(INITIAL_CACHE "${INITIAL_CACHE}
    ENABLE_UNITYBUILD=On
  " )
else(WIN32)
  SET(INITIAL_CACHE "${INITIAL_CACHE}
    BOOST_USE_STATIC=Off
  " )
endif(WIN32)

## Docu needs latex, packaging should require docu (although it might be copied.)
## This is a precheck before you build everything. During build it will be tested again.
if(BUILD_DOCU OR PACKAGE_TEST)
  message("You seem to need to build the documentation. Searching for LaTeX and Doxygen...")
  find_package(LATEX)
  if (NOT LATEX_FOUND)
    safe_message("Latex not found. You will need it to build the documentation with formulas.")
  else()
    safe_message("Latex found at ${LATEX_COMPILER}")
  endif()

  find_package(Doxygen)
  if(NOT DOXYGEN_FOUND)
    safe_message("Doxygen not found. You will need it to build any part of the documentation.")
  else()
    safe_message("Doxygen found at ${LATEX_COMPILER}")
  endif()
endif()

## If you set a custom compiler, pass it to the CMake calls
if(DEFINED ${C_COMPILER})
  SET(INITIAL_CACHE "${INITIAL_CACHE}
CMAKE_C_COMPILER:FILEPATH=${C_COMPILER}
CMAKE_CXX_COMPILER:FILEPATH=${CXX_COMPILER}
  " )
endif(DEFINED ${C_COMPILER})


## TODO Does the following add these flag or replace all flags? I assume the initial cache would be empty and
## therefore it basically adds the flags.
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
## TODO needs more testing if this works reliably.
#if(APPLE)
## if you want to use another SDK add the following also to the cache (usually not necessary)
## CMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.8.sdk/
## Anyway, we try to build relatively backwards compatible (10.6)
#  SET(INITIAL_CACHE "${INITIAL_CACHE}
#    CMAKE_OSX_DEPLOYMENT_TARGET=10.6
#  ")
#endif()
  
# Copy config file to customize errors (will be loaded later)
file(COPY "${SCRIPT_PATH}/CTestCustom.cmake" DESTINATION ${CTEST_BINARY_DIRECTORY})

## For now: Please start an XServer yourself, if you want to test TOPPView.
## TODO find a clean integration to CMake.
# if(UNIX)
#   # start virtual xserver (Xvnc) to test TOPPView
#   START_XSERVER(DISPLAY)
#   message(STATUS "Started X-Server on ${DISPLAY}")
# endif(UNIX)

if(BUILD_PYOPENMS)
	set(INITIAL_CACHE "${INITIAL_CACHE} PYOPENMS=ON")
          
	# http://stackoverflow.com/questions/22313407/clang-error-unknown-argument-mno-fused-madd-python-package-installation-fa
	# UPDATE [2014-05-16]: Apple has fixed this problem with updated system Pythons (2.7, 2.6, and 2.5) in OS X 10.9.3
	# so the workaround is no longer necessary when using the latest Mavericks and Xcode 5.1+.
	# However, as of now, the workaround is still required for OS X 10.8.x (Mountain Lion, currently 10.8.5)
	# if you are using Xcode 5.1+ there.

	set(ENV{CFLAGS} "-Qunused-arguments")
	set(ENV{CPPFLAGS} "-Qunused-arguments")
endif()


## Configuration finished!
# This is the initial cache to use for the binary tree, be careful to escape
# any quotes inside of this string if you use it
FILE(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${INITIAL_CACHE})

# do the dashboard/testings steps
# TODO make a variable out of it? E.g. MODEL
ctest_start  (Nightly)

ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")

# Reads the previously copied CTestCustom.cmake (which e.g. contains excluded warnings)
ctest_read_custom_files("${CTEST_BINARY_DIRECTORY}")


## The following might also be needed for XCode (e.g. all generators that build Projects)
## On our Mac machines this does not seem to affect the Makefile-based generators,
## so maybe we can always set it to OpenMS_host
if(WIN32)
  # So that windows uses the correct sln file (see https://gitlab.kitware.com/cmake/cmake/issues/12623)
  set(CTEST_PROJECT_NAME "OpenMS_host")
endif(WIN32)

ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")

if(WIN32)
  # Reset project name
  set(CTEST_PROJECT_NAME "OpenMS")
endif(WIN32)

# If we only tested style, all testing targets are deactivated (no topp, no class_tests, no pipeline)
if(NOT TEST_STYLE)
	ctest_test(BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL ${NUMBER_THREADS})
  ## TODO better put in the python_checker.cmake?
	if(BUILD_PYOPENMS)
		ctest_build(BUILD "${CTEST_BINARY_DIRECTORY}" TARGET pyopenms APPEND)
	endif()
	# adapt project name to allow xcode to find the test project
endif()

# E.g. for use with Jenkins or other Dashboards
if(CDASH_SUBMIT)
  ctest_submit()
endif()

if(TEST_COVERAGE)
  ctest_coverage(BUILD "${CTEST_BINARY_DIRECTORY}")
  if(CDASH_SUBMIT)
    ctest_submit(PARTS Coverage)
  endif()
endif()

if(RUN_CHECKER)
  include ( "${SCRIPT_PATH}/checker.cmake" )
endif()

if(RUN_PYTHON_CHECKER)
  include ( "${SCRIPT_PATH}/python_checker.cmake" )
endif()

if(BUILD_DOCU)
  include ( "${SCRIPT_PATH}/docu.cmake" )
endif()

if(EXTERNAL_CODE_TESTS)
  include ( "${SCRIPT_PATH}/external_code.cmake" )
endif()

if(PACKAGE_TEST)
  include ( "${SCRIPT_PATH}/package_test.cmake" )
endif()

if(KNIME_TEST)
  include ( "${SCRIPT_PATH}/knime_test.cmake" )
endif()
