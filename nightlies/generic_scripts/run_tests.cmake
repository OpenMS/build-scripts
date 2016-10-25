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

# Decide on CDash Track to use
if (OPENMS_BUILDNAME_PREFIX MATCHES "pr-.*")
  set(DASHBOARD_MODEL Continuous)
else()
  set(DASHBOARD_MODEL Nightly)
endif()
# ensure the config is known to ctest
set(CTEST_COMMAND "${CTEST_COMMAND} -D ${DASHBOARD_MODEL} -C ${BUILD_TYPE} ")

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

## TODO Should we automatically set BUILD_DOCU to true then?
if(PACKAGE_TEST AND NOT BUILD_DOCU)
  message("Warning: Packaging the build without building the full documentation.")
endif()
if(BUILD_DOCU)
  message("You seem to want to build the full documentation. Searching for (PDF)LaTeX and Doxygen...")
  find_package(Doxygen)
  find_package(LATEX)
  ## Copied from lemon build system. Added newer versions. Actually there are more...
  FIND_PROGRAM(GHOSTSCRIPT_EXECUTABLE
	  NAMES gs gswin32c
	  PATHS "$ENV{ProgramFiles}/gs"
	  PATH_SUFFIXES gs8.61/bin gs8.62/bin gs8.63/bin gs8.64/bin gs8.65/bin gs8.70/bin gs8.71/bin gs9.05/bin gs9.10/bin gs9.18/bin
	  DOC "Ghostscript: PostScript and PDF language interpreter and previewer."
	)
  if (NOT LATEX_COMPILER OR NOT DVIPS_CONVERTER OR NOT GHOSTSCRIPT_EXECUTABLE)
    safe_message("Latex, dvips or ghostscript not found. You will need them to build the standard html documentation with formulas. ")
  else()
    safe_message("Latex found at ${LATEX_COMPILER}, dvips found at ${DVIPS_CONVERTER}, ghostscript found at ${GHOSTSCRIPT_EXECUTABLE}")
  endif()
  
  if (NOT PDFLATEX_COMPILER OR NOT MAKEINDEX_COMPILER)
    safe_message("pdflatex/makeindex not found. You will need it to build the tutorials. ")
  else()
    safe_message("PDFLatex found at ${PDFLATEX_COMPILER}")
  endif()

  if(NOT DOXYGEN_FOUND)
    safe_message("Doxygen not found. You will need it to build any part of the documentation.")
  else()
    safe_message("Doxygen found at ${DOXYGEN_EXECUTABLE}")
  endif()
endif()

## If you set a custom compiler, pass it to the CMake calls
if(DEFINED ${C_COMPILER})
  SET(INITIAL_CACHE "${INITIAL_CACHE}
CMAKE_C_COMPILER:FILEPATH=${C_COMPILER}
CMAKE_CXX_COMPILER:FILEPATH=${CXX_COMPILER}
  " )
endif(DEFINED ${C_COMPILER})

##Error(s) while accumulating results:
##  Problem reading source file: /home/jenkins/workspace/openms_linux/025a6a2d/source/src/openms/include/OpenMS/DATASTRUCTURES/Map.h line:166  out total: 191
## Fixed in 2.8.7, but soon reverted in favor of CTEST_COVERAGE_EXTRA_FLAGS variable. However, until CMake 3.1 this variable is not respected
## in Ctest scripts but only from the CLI of ctest
## TODO require CMake 3.1 for coverage or use custom commands
if(TEST_COVERAGE)
  SET(CTEST_COVERAGE_EXTRA_FLAGS "-l -p -r -s ${CTEST_SOURCE_DIRECTORY}")
  SET(INITIAL_CACHE "${INITIAL_CACHE}
CMAKE_C_FLAGS:STRING=-fprofile-arcs -ftest-coverage
CMAKE_CXX_FLAGS:STRING=-fprofile-arcs -ftest-coverage
CMAKE_EXE_LINKER_FLAGS:STRING=-fprofile-arcs -ftest-coverage
CMAKE_MODULE_LINKER_FLAGS:STRING=-fprofile-arcs -ftest-coverage
CMAKE_SHARED_LINKER_FLAGS:STRING=-fprofile-arcs -ftest-coverage
COVERAGE_COMMAND:STRING=${CTEST_COVERAGE_COMMAND}
CTEST_COVERAGE_COMMAND:STRING=${CTEST_COVERAGE_COMMAND}
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

##TODO check which OSX version
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
ctest_start  (${DASHBOARD_MODEL})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")

# Reads the previously copied CTestCustom.cmake (which e.g. contains excluded warnings)
ctest_read_custom_files("${CTEST_BINARY_DIRECTORY}")

# If we are testing style, the usual test targets are replaced (it instead
# runs cppcheck/lint on every file and parses the output with a regex)
if(NOT TEST_STYLE)
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
    
    ## Test the normal testing suite
    ## TODO make this a global param so that one can disable the usual test suite
    set (SKIP_TESTS Off)
    if(NOT SKIP_TESTS)
        ctest_test(BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL ${NUMBER_THREADS})

        # Coverage only makes sense with normal testing suite. (no style)
        # TODO Test it more thoroughly and/or switch to the new method for generating a coverage report.
        # Because I think Coverage report are a bit hidden in CDash
        if(TEST_COVERAGE)
            ctest_coverage(BUILD "${CTEST_BINARY_DIRECTORY}")
        endif()
        # E.g. for use with Jenkins or other Dashboards you can disable submission
        if(CDASH_SUBMIT)
            # Submit all
            ctest_submit()
        endif()
        # Checker needs tests to be executed. Overwrites tests
        if(RUN_CHECKER)
            # TODO Clean up checker script. Add dependency on doc_xml and doc_internal.
            include ( "${SCRIPT_PATH}/checker.cmake" )
        endif()
    endif()
else()
    ## Only test the style tests
    ctest_test(BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL ${NUMBER_THREADS})
    # E.g. for use with Jenkins or other Dashboards you can disable submission
    if(CDASH_SUBMIT)
        # Submit all
        ctest_submit()
    endif()
endif()

## The python-checker tool only needs the class documentation in xml (target: doc_xml)
## Otherwise it can be executed independently from building pyOpenMS
## Nonetheless group the outputs into a single CDash submission entry when both are executed.
if(BUILD_PYOPENMS OR RUN_PYTHON_CHECKER)
    ctest_start(TRACK pyOpenMS)
    if(BUILD_PYOPENMS)
        ctest_build(BUILD "${CTEST_BINARY_DIRECTORY}" TARGET pyopenms APPEND)
    endif()
    if(RUN_PYTHON_CHECKER)
        ##TODO cleanup the include script. Remove ctest_start, ctest_submit, change of buildname
        include ( "${SCRIPT_PATH}/python_checker.cmake" )
    endif()
    ctest_submit()
endif()

## To build full html documentation with Tutorials.
if(BUILD_DOCU)
  include ( "${SCRIPT_PATH}/docu.cmake" )
endif()

## Needs only our libraries
if(EXTERNAL_CODE_TESTS)
  include ( "${SCRIPT_PATH}/external_code.cmake" )
endif()

## Usually built with documentation
if(PACKAGE_TEST)
  include ( "${SCRIPT_PATH}/package_test.cmake" )
endif()

## Relatively independent from the rest. Needs THIRDPARTY binaries.
if(KNIME_TEST)
  include ( "${SCRIPT_PATH}/knime_test.cmake" )
endif()
