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

# Check for required variables.
set(required_variables
	"CTEST_SOURCE_DIRECTORY;CTEST_BINARY_DIRECTORY;INITIAL_CACHE;CTEST_BUILD_NAME")

backup_and_check_variables(required_variables)

set(SEARCH_ENGINES_DIRECTORY "/Users/aiche/NIGHTLY/SEARCHENGINES/")

set(BUNDLE_NAME "OpenMS-2.0.0-Darwin.dmg")

if(DEFINED GIT_BRANCH)
set(TARGET_NAME "OpenMS-2.0.0-${GIT_BRANCH}.dmg")
else()
set(TARGET_NAME "OpenMS-2.0.0-HEAD.dmg")
endif()

set(CTEST_BUILD_NAME "${CTEST_BUILD_NAME}_Package")

# update the source tree
message("Executing ${CMAKE_COMMAND} -D PACKAGE_TYPE=dmg ${CTEST_SOURCE_DIRECTORY}")
message("Working directory is ${CTEST_BINARY_DIRECTORY}")

execute_process(COMMAND
	${CMAKE_COMMAND}
	-D
	PACKAGE_TYPE=dmg
	-DSEARCH_ENGINES_DIRECTORY=${SEARCH_ENGINES_DIRECTORY}
	-D
	LATEX_COMPILER:FILEPATH=/usr/texbin/latex
	-D
	PDFLATEX_COMPILER:FILEPATH=/usr/texbin/pdflatex
	${CTEST_SOURCE_DIRECTORY}
	WORKING_DIRECTORY
	"${CTEST_BINARY_DIRECTORY}/"
	RESULT_VARIABLE
	RECONFIGURE_FOR_PACKAGE_BUILD
	OUTPUT_VARIABLE
	RECONFIGURE_FOR_PACKAGE_BUILD_OUT
	ERROR_VARIABLE
	RECONFIGURE_FOR_PACKAGE_BUILD_OUT)

if(NOT RECONFIGURE_FOR_PACKAGE_BUILD EQUAL 0)
	message("Could not reconfigure ${CTEST_BINARY_DIRECTORY} for package build")
	message(FATAL_ERROR
		"reconfigure resulted in: ${RECONFIGURE_FOR_PACKAGE_BUILD}")
endif()

# and once again, just to make the doc targets are there
execute_process(COMMAND
	${CMAKE_COMMAND}
	.
	WORKING_DIRECTORY
	"${CTEST_BINARY_DIRECTORY}/")

set($ENV{PATH} "${CTEST_BINARY_DIRECTORY}/bin:$ENV{PATH}")

# build the package and submit the results to cdash
ctest_start(Nightly)
ctest_build(BUILD "${CTEST_BINARY_DIRECTORY}" TARGET doc)
ctest_build(BUILD
	"${CTEST_BINARY_DIRECTORY}"
	TARGET
	doc_tutorials
	APPEND)
ctest_build(BUILD "${CTEST_BINARY_DIRECTORY}" TARGET package APPEND)
ctest_submit(PARTS Build)

# copy package to destination
file(RENAME
	${CTEST_BINARY_DIRECTORY}/${BUNDLE_NAME}
	${CTEST_BINARY_DIRECTORY}/${TARGET_NAME})
#file(
#	COPY ${CTEST_BINARY_DIRECTORY}/${TARGET_NAME}
#	DESTINATION ${PACKAGE_TARGET_PATH}
#)

execute_process(COMMAND
	rsync
	-avz
	${CTEST_BINARY_DIRECTORY}/${TARGET_NAME}
	login.imp.fu-berlin.de:/web/ftp.mi.fu-berlin.de/pub/OpenMS/nightly_binaries/
	WORKING_DIRECTORY
	"${CTEST_BINARY_DIRECTORY}/")

restore_variables(required_variables)
