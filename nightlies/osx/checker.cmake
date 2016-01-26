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

# checker.cmake
# BRIEF:  This script adds an extra CTEST_TEST to the test script, that
#         includes it. In this script the OpenMS checker will be executed
#         and the output will be copied to a specified directory

# check required variables
if(NOT DEFINED OPENMS_BUILDNAME_PREFIX)
	set(OPENMS_BUILDNAME_PREFIX "")	# empty prefix indicates head
endif()

if(NOT DEFINED CHECKER_TARGET_PATH)
	message(STATUS "CHECKER_TARGET_PATH variable must be set")
	message(FATAL_ERROR "Script aborted!!!")
endif()

# now we hack our own checker into cdash
macro(ctest_test)
	execute_process(COMMAND
		make
		test_build
		WORKING_DIRECTORY
		${CTEST_BINARY_DIRECTORY})

	execute_process(COMMAND
		make
		test
		WORKING_DIRECTORY
		${CTEST_BINARY_DIRECTORY})

	execute_process(COMMAND
		php
		tools/checker.php
		${CTEST_SOURCE_DIRECTORY}
		${CTEST_BINARY_DIRECTORY}
		-s
		svn_keywords
		OUTPUT_FILE
		${CTEST_BINARY_DIRECTORY}/${OPENMS_BUILDNAME_PREFIX}checker.log
		WORKING_DIRECTORY
		${CTEST_SOURCE_DIRECTORY})

	file(COPY
		${CTEST_BINARY_DIRECTORY}/${OPENMS_BUILDNAME_PREFIX}checker.log
		DESTINATION
		${CHECKER_TARGET_PATH})
endmacro()

# test again with new macro
ctest_test(BUILD "${CTEST_BINARY_DIRECTORY}")
