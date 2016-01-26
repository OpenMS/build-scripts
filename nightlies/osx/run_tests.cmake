# --------------------------------------------------------------------------
#                   OpenMS -- Open-Source Mass Spectrometry
# --------------------------------------------------------------------------
# Copyright The OpenMS Team -- Eberhard Karls University Tuebingen,
# ETH Zurich, and Freie Universitaet Berlin 2002-2012.
#
# This software is released under a three-clause BSD license:
#  * Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#  * Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#  * Neither the name of any author or any participating institution
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
# For a full list of authors, refer to the file AUTHORS.
# --------------------------------------------------------------------------
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL ANY OF THE AUTHORS OR THE CONTRIBUTING
# INSTITUTIONS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# --------------------------------------------------------------------------
# $Maintainer: Stephan Aiche $
# $Authors: Stephan Aiche $
# --------------------------------------------------------------------------

# fix generator name as it may has spaces in it
string(REGEX REPLACE "[ ]" "_" GENERATOR_NAME ${GENERATOR})
set(CTEST_BUILD_NAME
	"${OPENMS_BUILDNAME_PREFIX}${SYSTEM_IDENTIFIER}-${COMPILER_IDENTIFIER}-${GENERATOR_NAME}-${BUILD_TYPE}")

## append additional information to the build name
if(TEST_COVERAGE)
	set(CTEST_BUILD_NAME "${CTEST_BUILD_NAME}-Coverage")
elseif(TEST_STYLE)
	set(CTEST_BUILD_NAME "${CTEST_BUILD_NAME}-Style")
endif()

# set variables describing the build environments
set(CTEST_BINARY_DIRECTORY "${BUILD_DIRECTORY}/${CTEST_BUILD_NAME}")
set(required_variables
	"PACKAGE_TEST;EXTERNAL_CODE_TESTS;SCRIPT_PATH;CTEST_SOURCE_DIRECTORY;CXX_COMPILER;C_COMPILER;CTEST_GIT_COMMAND;CTEST_BINARY_DIRECTORY;OPENMS_CONTRIB;BUILD_TYPE;QT_QMAKE")

foreach(var IN LISTS required_variables)
	if(NOT DEFINED ${var})
		safe_message(FATAL_ERROR
			"Variable <${var}> needs to be set to run this script")
	endif()
endforeach()

set(not_required
	"TEST_COVERAGE;RUN_CHECKER;BUILD_DOCU;BUILD_PYOPENMS;RUN_PYTHON_CHECKER")
if(NOT DEFINED ${var})
	set(${var} Off)
endif()

#check requirements for coverage build
if(TEST_COVERAGE)
	if(NOT DEFINED CTEST_COVERAGE_COMMAND)
		safe_message(FATAL_ERROR
			"CTEST_COVERAGE_COMMAND needs to be set for coverage builds")
	endif()
endif()

# try to get as much warnings/errors as possible
set(CTEST_CUSTOM_MAXIMUM_NUMBER_OF_ERRORS 10000)
set(CTEST_CUSTOM_MAXIMUM_NUMBER_OF_WARNINGS 10000)

# define generator
set(CTEST_CMAKE_GENERATOR "${GENERATOR}")
set(CTEST_BUILD_CONFIGURATION "${BUILD_TYPE}")
set(CTEST_COMMAND "${CTEST_COMMAND} -D Nightly -C ${BUILD_TYPE} ")

# clear the binary directory to avoid problems
ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})

# customize warnings/errors
file(COPY "/Users/aiche/NIGHTLY/scripts/CTestCustom.cmake" DESTINATION ${CTEST_BINARY_DIRECTORY})

set(INITIAL_CACHE
	"
CMAKE_FIND_ROOT_PATH:PATH=${OPENMS_CONTRIB}
CMAKE_BUILD_TYPE:STRING=${BUILD_TYPE}
CMAKE_GENERATOR:INTERNAL=${GENERATOR}
QT_QMAKE_EXECUTABLE:FILEPATH=${QT_QMAKE}
SVNCOMMAND:FILEPATH=${CTEST_SVN_COMMAND}
SVNVERSION_EXECUTABLE:FILEPATH=${CTEST_SVN_COMMAND}version
CMAKE_C_COMPILER:FILEPATH=${C_COMPILER}
CMAKE_CXX_COMPILER:FILEPATH=${CXX_COMPILER}
MAKECOMMAND:STRING=/usr/bin/make -i -j2
LATEX_COMPILER:FILEPATH=/usr/texbin/latex
PDFLATEX_COMPILER:FILEPATH=/usr/texbin/pdflatex
CMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.8.sdk/
CMAKE_OSX_DEPLOYMENT_TARGET=10.6
")

if(TEST_COVERAGE)
	set(INITIAL_CACHE
		"${INITIAL_CACHE}
CMAKE_C_FLAGS:STRING=-fprofile-arcs -ftest-coverage
CMAKE_CXX_FLAGS:STRING=-fprofile-arcs -ftest-coverage
CMAKE_EXE_LINKER_FLAGS:STRING=-fprofile-arcs -ftest-coverage
CMAKE_MODULE_LINKER_FLAGS:STRING=-fprofile-arcs -ftest-coverage
CMAKE_SHARED_LINKER_FLAGS:STRING=-fprofile-arcs -ftest-coverage")
endif()

if(TEST_STYLE)
	set(INITIAL_CACHE "${INITIAL_CACHE}
ENABLE_STYLE_TESTING:BOOL=On")
endif()

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
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${INITIAL_CACHE})

# customizing PATH so ExecutePipeline_test finds its executables
set(ENV{PATH} "${CTEST_BINARY_DIRECTORY}/bin:$ENV{PATH}")

# do the dashboard/testings steps
ctest_start(Nightly)
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
ctest_configure(BUILD "${CTEST_BINARY_DIRECTORY}")
set(CTEST_PROJECT_NAME "OpenMS_host")
if(NOT TEST_STYLE)
	ctest_build(BUILD "${CTEST_BINARY_DIRECTORY}" APPEND)
	if(BUILD_PYOPENMS)
		ctest_build(BUILD "${CTEST_BINARY_DIRECTORY}" TARGET pyopenms APPEND)
	endif()
	# adapt project name to allow xcode to find the test project
endif()
ctest_test(BUILD "${CTEST_BINARY_DIRECTORY}")


if(TEST_COVERAGE)
	ctest_coverage(BUILD "${CTEST_BINARY_DIRECTORY}")
endif()

ctest_submit()

if(RUN_CHECKER)
	include("${SCRIPT_PATH}/checker.cmake")
endif()

if(RUN_PYTHON_CHECKER)
	include("${SCRIPT_PATH}/python_checker.cmake")
endif()

if(BUILD_DOCU)
	include("${SCRIPT_PATH}/docu.cmake")
endif()

if(EXTERNAL_CODE_TESTS)
	include("${SCRIPT_PATH}/external_code.cmake")
endif()

if(PACKAGE_TEST)
	include("${SCRIPT_PATH}/package_test.cmake")
endif()
