## Set non-required boolean variables to "Off" if not present
set (not_required_bool "KNIME_TEST;PACKAGE_TEST;EXTERNAL_CODE_TESTS;TEST_COVERAGE;TEST_STYLE;BUILD_PYOPENMS;RUN_CHECKER;RUN_PYTHON_CHECKER;BUILD_DOCU;RERUN")

foreach(var IN LISTS not_required_bool)
  ## if undefined or not configured:
  if(NOT DEFINED ${var} OR ${var} MATCHES "\@*\@")
    set(${var} Off)
  endif()
endforeach()

## Check for all required variables that have to be set in the main script and raise errors
set(required_variables "OPENMS_BUILDNAME_PREFIX;SYSTEM_IDENTIFIER;COMPILER_IDENTIFIER;SCRIPT_PATH;CTEST_SOURCE_DIRECTORY;CONTRIB;BUILD_TYPE;QT_QMAKE_BIN_PATH;GENERATOR")

foreach(var IN LISTS required_variables)
  if(NOT DEFINED ${var})
    safe_message(FATAL_ERROR "Variable <${var}> needs to be set to run this script")
  endif()
endforeach()

## Unset non-required string variables if not present
set (not_required_str "OPENMS_INSTALL_DIR;NUMBER_THREADS;CTEST_COVERAGE_COMMAND")

foreach(var IN LISTS not_required_str)
  if(NOT DEFINED ${var} OR ${var} MATCHES "\@*\@")
    unset(${var})
  endif()
endforeach()

## Add user paths to CMAKE_PREFIX_PATH to help in the search of libraries and programs
set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} ${CONTRIB})

## For parallel building

## CTEST_BUILD_FLAGS will be used in later ctest_build()'s
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
  # We could determine max nr of cpus with the ProcessorCount module but especially with Jenkins
  # You do not want to always use ALL cores possible.
  set(NUMBER_THREADS "1")
endif()

## Compiler identifier is e.g. MSVC10x64 or gcc4.9 or clang3.3
SET (CTEST_BUILD_NAME "${OPENMS_BUILDNAME_PREFIX}-${SYSTEM_IDENTIFIER}-${COMPILER_IDENTIFIER}-${BUILD_TYPE}")

## check requirements for special CTest features (style/coverage) and append additional information to the build name
## TODO Requires GCC or newer Clang as compiler, maybe test here.
## TODO Think about putting these settings into own CMakes like the other options.
## TODO Use new OpenMS_coverage target
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
endif()

## Package dependent requirements
## TODO Actually KNIME_TEST needs full Java SDK because of jar.exe.
find_package(Java)
if(NOT $ENV{SEARCH_ENGINES_DIRECTORY})
  if($ENV{ENABLE_PREPARE_KNIME_PACKAGE} OR $ENV{PACKAGE_TEST})
    safe_message(FATAL_ERROR "Trying to build a package or KNIME plugin without setting the path to the Thirdparty binaries (SEARCH_ENGINES_DIRECTORY)")
  else()
    safe_message("Warning: Trying to test OpenMS without setting the path to the Thirdparty binaries (SEARCH_ENGINES_DIRECTORY). This will disable their tests.")
  endif()
else()
  if($ENV{ENABLE_TOPP_TESTING})
      if(NOT Java_JAVA_EXECUTABLE)
        safe_message(FATAL_ERROR "Error: Trying to test Thirdparty tools without Java. Some of them require a JRE. Please add it to the path environment variable or the CMAKE_PREFIX_PATH")
      endif()
      get_filename_component(JAVA_BIN_DIR ${Java_JAVA_EXECUTABLE} DIRECTORY)
      safe_message("Adding ${JAVA_BIN_DIR} to path for Thirdparty tests.")
      if(WIN32)
        SUBDIRLIST(SUBDIRS $ENV{SEARCH_ENGINES_DIRECTORY})
        FOREACH(subdir ${SUBDIRS})
          set (CTEST_ENVIRONMENT "PATH=$ENV{SEARCH_ENGINES_DIRECTORY}/${subdir}\;$ENV{PATH}" "Path=$ENV{SEARCH_ENGINES_DIRECTORY}/${subdir}\;$ENV{Path}")
          set (ENV{PATH} "$ENV{SEARCH_ENGINES_DIRECTORY}/${subdir}\;$ENV{PATH}")
          set (ENV{Path} "$ENV{SEARCH_ENGINES_DIRECTORY}/${subdir}\;$ENV{Path}")
          safe_message("Added $ENV{SEARCH_ENGINES_DIRECTORY}/${subdir} to the PATH enviroment used by CMake and CTest.")
        ENDFOREACH()
        set (CTEST_ENVIRONMENT "PATH=${JAVA_BIN_DIR}\;$ENV{PATH}" "Path=${JAVA_BIN_DIR}\;$ENV{Path}")
        set (ENV{PATH} "${JAVA_BIN_DIR}\;$ENV{PATH}")
        set (ENV{Path} "${JAVA_BIN_DIR}\;$ENV{Path}")
      else()
        # Add Search Engine test binaries to PATH, such that tests are automatically enabled.
        SUBDIRLIST(SUBDIRS $ENV{SEARCH_ENGINES_DIRECTORY})
        FOREACH(subdir ${SUBDIRS})
          set (CTEST_ENVIRONMENT "PATH=$ENV{SEARCH_ENGINES_DIRECTORY}/${subdir}:$ENV{PATH}")
          set (ENV{PATH} "$ENV{SEARCH_ENGINES_DIRECTORY}/${subdir}:$ENV{PATH}")
          safe_message("Added $ENV{SEARCH_ENGINES_DIRECTORY}/${subdir} to the PATH enviroment used by CMake and CTest.")
        ENDFOREACH()
        set (CTEST_ENVIRONMENT "PATH=${JAVA_BIN_DIR}:$ENV{PATH}")
        set (ENV{PATH} "${JAVA_BIN_DIR}:$ENV{PATH}")
      endif()
  endif()
endif()

if($ENV{ENABLE_PREPARE_KNIME_PACKAGE} AND NOT Java_JAR_EXECUTABLE)
  safe_message(FATAL_ERROR "Packaging binaries for KNIME requires the JAR executable (usually installed with the SDK). Put it in the (CMAKE_PREFIX_)PATH.")
endif()

## Translate to "official" CTEST variables
set (CTEST_BINARY_DIRECTORY "$ENV{BUILD_DIR}")
## Not sure if the next one is needed
set (CTEST_BINARY_TEST_DIRECTORY "${CTEST_BINARY_DIRECTORY}/source/TEST/")
set (CTEST_CMAKE_GENERATOR "$ENV{GENERATOR}" )
set (CTEST_BUILD_CONFIGURATION "$ENV{BUILD_TYPE}")

# Setup Paths for the tests (e.g. ExecutePipeline)
if(WIN32)
  ## VS is always multiconf
  set (BINARY_DIR "${CTEST_BINARY_DIRECTORY}/bin/${BUILD_TYPE}")
  set (CTEST_ENVIRONMENT "PATH=${BINARY_DIR}\;$ENV{PATH}" "Path=${BINARY_DIR}\;$ENV{Path}")
  set (ENV{PATH} "${BINARY_DIR}\;$ENV{PATH}")
  set (ENV{Path} "${BINARY_DIR}\;$ENV{Path}")

  # Setup additional environment variables for windows, so that dependencies are foudn during execution
  ## Add rest (e.g. QT, CONTRIB)
  set (CTEST_ENVIRONMENT "PATH=${QT_QMAKE_BIN_PATH}\;${CONTRIB}/lib\;$ENV{PATH}" "Path=$ENV{QT_QMAKE_BIN_PATH}\;${CONTRIB}/lib\;$ENV{Path}")
  set (ENV{PATH} "$ENV{QT_QMAKE_BIN_PATH}\;${CONTRIB}/lib\;$ENV{PATH}")
  set (ENV{Path} "$ENV{QT_QMAKE_BIN_PATH}\;${CONTRIB}/lib\;$ENV{Path}")
else(WIN32)
  ## Multi config like Xcode?
  if(GENERATOR STREQUAL "XCode")
    set (BINARY_DIR "${CTEST_BINARY_DIRECTORY}/bin/$ENV{BUILD_TYPE}")
  else()
    set (BINARY_DIR "${CTEST_BINARY_DIRECTORY}/bin/")
  endif()
  set (ENV{PATH} "${BINARY_DIR}:$ENV{PATH}")
endif()

# Decide on CDash Dashboard model to use
# Mainly cosmetic reasons since we do not use ctest_update
# Might change how the Testing folders are generated.
if (OPENMS_BUILDNAME_PREFIX MATCHES "pr-.*")
  set(DASHBOARD_MODEL Continuous)
elseif(OPENMS_BUILDNAME_PREFIX STREQUAL "develop" OR OPENMS_BUILDNAME_PREFIX STREQUAL "master")
  set(DASHBOARD_MODEL Nightly)
else()
  set(DASHBOARD_MODEL Experimental)
endif()
# ensure the config is known to ctest
set(CTEST_COMMAND "${CTEST_COMMAND} -D ${DASHBOARD_MODEL} -C ${BUILD_TYPE} ")

# If it was set, use custom install dir (e.g. because of missing write permissions in system paths)
# Packaging calls the install target.
if(OPENMS_INSTALL_DIR)
  SET(INITIAL_CACHE "${INITIAL_CACHE}
    CMAKE_INSTALL_PREFIX:PATH=${OPENMS_INSTALL_DIR}
    ")
  message("Warning: CMAKE_INSTALL_PREFIX cache variable for following CMake calls is overwritten/set to ${OPENMS_INSTALL_DIR}.")
endif()

SET(INITIAL_CACHE "${INITIAL_CACHE}
CMAKE_PREFIX_PATH:PATH=${CMAKE_PREFIX_PATH}
CMAKE_BUILD_TYPE:STRING=$ENV{BUILD_TYPE}
CMAKE_GENERATOR:INTERNAL=$ENV{GENERATOR}
QT_QMAKE_EXECUTABLE:FILEPATH=$ENV{QT_QMAKE_BIN_PATH}/qmake
ENABLE_TOPP_TESTING:BOOL=$ENV{ENABLE_TOPP_TESTING}
ENABLE_CLASS_TESTING:BOOL=$ENV{ENABLE_CLASS_TESTING}
ENABLE_STYLE_TESTING:BOOL=$ENV{ENABLE_STYLE_TESTING}
WITH_GUI:BOOL=$ENV{WITH_GUI}
DISABLE_WAVELET2DTEST:BOOL=$ENV{DISABLE_WAVELET2DTEST}
ADDRESS_SANITIZER:BOOL=$ENV{ADDRESS_SANITIZER}
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

## Docu needs latex, packaging requires full docu (although it might be copied from somewhere with a custom script).
## This is a precheck before you build everything. During build it will be tested again.
find_package(Doxygen)
find_package(LATEX)
if($ENV{BUILD_FULL_DOC} OR $ENV{PACKAGE_TEST})
  message("You seem to want to build the full documentation. Searching for (PDF)LaTeX and Doxygen before building...")
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
if(DEFINED $ENV{CC})
  SET(INITIAL_CACHE "${INITIAL_CACHE}
CMAKE_C_COMPILER:FILEPATH=$ENV{CC}
CMAKE_CXX_COMPILER:FILEPATH=$ENV{CXX}
  " )
endif()

##Error(s) while accumulating results:
##  Problem reading source file: /home/jenkins/workspace/openms_linux/025a6a2d/source/src/openms/include/OpenMS/DATASTRUCTURES/Map.h line:166  out total: 191
## Fixed in 2.8.7, but soon reverted in favor of CTEST_COVERAGE_EXTRA_FLAGS variable. However, until CMake 3.1 this variable is not respected
## in Ctest scripts but only from the CLI of ctest
## TODO require CMake 3.1 for coverage or use new make target OpenMS_coverage
if($ENV{TEST_COVERAGE})
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

##TODO check which OSX version
if($ENV{PYOPENMS})
	set(INITIAL_CACHE "${INITIAL_CACHE} PYOPENMS=$ENV{PYOPENMS}")
          
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

# Reads the previously copied CTestCustom.cmake (which e.g. contains excluded warnings)
ctest_read_custom_files("${CTEST_BINARY_DIRECTORY}")

# If we are testing style, the usual test targets are replaced and we do not need to build (it instead
# runs cppcheck/lint on every file and parses the output with a regex)
# TODO requires python??
# TODO put in own cmake script
if($ENV{ENABLE_STYLE_TESTING)
    set(OLD_CTEST_BUILD_NAME ${CTEST_BUILD_NAME})
    set(CTEST_BUILD_NAME ${CTEST_BUILD_NAME}_Style)
    ctest_start(${DASHBOARD_MODEL} TRACK Style)
    ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}" OPTIONS "-DENABLE_STYLE_TESTING=On")
    ctest_test(BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL ${NUMBER_THREADS})
    # E.g. for use with Jenkins or other Dashboards you can disable submission
    if(CDASH_SUBMIT)
        # Submit all
        ctest_submit()
    endif()
    set(CTEST_BUILD_NAME ${OLD_CTEST_BUILD_NAME})
endif()

if($ENV{ENABLE_TOPP_TESTING} OR $ENV{ENABLE_CLASS_TESTING})
    # Do actual tool and class tests
    ctest_start  (${DASHBOARD_MODEL})
    # Reconfigure with style testing off. Class&TOPP are already in the InitialCache but "shadowed" by Style.
    ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}" OPTIONS "-DENABLE_STYLE_TESTING=Off")
    ## The following might also be needed for XCode (e.g. all generators that build Projects)
    ## On our Mac machines this does not seem to affect the Makefile-based generators,
    ## so maybe we can always set it to OpenMS_host
    if(WIN32)
        # So that windows uses the correct sln file (see https://gitlab.kitware.com/cmake/cmake/issues/12623)
        set(CTEST_PROJECT_NAME "OpenMS_host")
    endif(WIN32)

    ## i.e. make all target
    ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")

    if(WIN32)
        # Reset project name
        set(CTEST_PROJECT_NAME "OpenMS")
    endif(WIN32)
    
    ctest_test(BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL ${NUMBER_THREADS})

    # Coverage only makes sense with normal testing suite. (no style)
    # TODO Test it more thoroughly and/or switch to the new method for generating a coverage report.
    # Because I think Coverage reports are a bit hidden in CDash
    if($ENV{TEST_COVERAGE})
        ctest_coverage(BUILD "${CTEST_BINARY_DIRECTORY}")
    endif()
    # E.g. for use with Jenkins or other Dashboards you can disable submission
    if(CDASH_SUBMIT)
        # Submit all
        ctest_submit()
    endif()
    # Checker needs tests to be executed. Overwrites current Test.xml but creates a backup.
    if($ENV{RUN_CHECKER})
        include( "${SCRIPT_PATH}/FindPHP.cmake")
        find_package(php)
        if(NOT DOXYGEN_FOUND OR NOT PHP_EXECUTABLE)
          safe_message(FATAL_ERROR "The Checker script needs PHP and Doxygen to check for errors.")
        endif()
        # TODO Clean up checker script. Add dependency on doc_xml and doc_internal.
        include ( "${SCRIPT_PATH}/checker.cmake" )
    endif()
endif()

## The python-checker tool only needs the class documentation in xml (target: doc_xml)
## Otherwise it can be executed independently from building pyOpenMS
## Nonetheless group the outputs into a single CDash submission entry when both are executed.
if($ENV{PYOPENMS} OR $ENV{RUN_PYTHON_CHECKER})
    ctest_start(${DASHBOARD_MODEL} TRACK PyOpenMS)
    if($ENV{PYOPENMS})
        ctest_build(BUILD "${CTEST_BINARY_DIRECTORY}" TARGET pyopenms APPEND)
        set(PYOPENMS_BUILT On)
    endif()
    if($ENV{RUN_PYTHON_CHECKER})
        ##TODO cleanup the include script. Remove ctest_start, ctest_submit, change of buildname
        include ( "${SCRIPT_PATH}/python_checker.cmake" )
    endif()
    ctest_submit()
endif()

## To build full html documentation with Tutorials.
if($ENV{BUILD_DOCU})
  include ( "${SCRIPT_PATH}/docu.cmake" )
endif()

## Needs only our libraries
if($ENV{EXTERNAL_CODE_TESTS})
  include ( "${SCRIPT_PATH}/external_code.cmake" )
endif()

## Additionally builds full documentation.
## TODO check if it actually is not executed twice. It probably is -.-
if($ENV{PACKAGE_TEST})
  include ( "${SCRIPT_PATH}/package_test.cmake" )
endif()

## Relatively independent from the rest. Needs THIRDPARTY binaries and TOPP, UTILS.
if($ENV{ENABLE_PREPARE_KNIME_PACKAGE})
  include ( "${SCRIPT_PATH}/knime_test.cmake" )
endif()
