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

if(NOT DEFINED TEST_MACROS_INCLUDED)
	include(/group/agabi/OpenMS/nightly-builds/scripts/test_macros.cmake)
endif()

# Check for required variables.
set(required_variables
	"CTEST_SOURCE_DIRECTORY;CTEST_BINARY_DIRECTORY;INITIAL_CACHE;CTEST_BUILD_NAME")

backup_and_check_variables(required_variables)

## external project:
set(CTEST_SOURCE_TESTEXTERNAL_DIRECTORY
	"${CTEST_SOURCE_DIRECTORY}/source/TEST/EXTERNAL/")
set(CTEST_BINARY_TESTEXTERNAL_DIRECTORY
	"${CTEST_BINARY_DIRECTORY}/source/TEST/EXTERNAL/")

set(CTEST_ENVIRONMENT "OPENMS_BUILD_TREE=${CTEST_BINARY_DIRECTORY}")

## extend initial cache with references to
## the OpenMS directory
set(INITIAL_CACHE
	"${INITIAL_CACHE}
OpenMS_DIR:PATH=${CTEST_BINARY_DIRECTORY}/cmake
")

## (re)define build name and test directories
set(CTEST_BUILD_NAME "${CTEST_BUILD_NAME}_External")
set(CTEST_SOURCE_DIRECTORY ${CTEST_SOURCE_TESTEXTERNAL_DIRECTORY})
set(CTEST_BINARY_DIRECTORY ${CTEST_BINARY_TESTEXTERNAL_DIRECTORY})

set(CTEST_PROJECT_NAME "OpenMS_external_code_test")

ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})

file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${INITIAL_CACHE})

ctest_start(Nightly)
ctest_configure(BUILD "${CTEST_BINARY_TESTEXTERNAL_DIRECTORY}")
ctest_build(BUILD "${CTEST_BINARY_TESTEXTERNAL_DIRECTORY}")
ctest_test(BUILD "${CTEST_BINARY_TESTEXTERNAL_DIRECTORY}")
ctest_submit(PARTS Configure Build Test)

restore_variables(required_variables)