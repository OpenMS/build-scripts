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

# docu.cmake
# BRIEF:  This script add an extra CTEST_BUILD to the test script, that
#         includes building the documentation and uploading it to a
#         specified destination.

# check required variables
if(NOT DEFINED OPENMS_BUILDNAME_PREFIX)
	set(OPENMS_BUILDNAME_PREFIX "")	# empty prefix indicates head
	message(STATUS "Setting prefix")
endif()

if(NOT DEFINED DOCU_TARGET_PATH)
	message(STATUS "DOCU_TARGET_PATH variable must be set")
	message(FATAL_ERROR "Script aborted!!!")
endif()


# now we hack building the documentation into cdash
macro(ctest_test)
	message(STATUS "make doc")
	execute_process(COMMAND
		make
		doc
		WORKING_DIRECTORY
		${CTEST_BINARY_DIRECTORY})

	message(STATUS
		"cmake -E remove_directory ${DOCU_TARGET_PATH}${OPENMS_BUILDNAME_PREFIX}documentation/")
	execute_process(COMMAND
		cmake
		-E
		remove_directory
		${DOCU_TARGET_PATH}${OPENMS_BUILDNAME_PREFIX}documentation/
		WORKING_DIRECTORY
		${CTEST_BINARY_DIRECTORY})

	message(STATUS
		"cmake -E copy_directory ${CTEST_BINARY_DIRECTORY}/doc/ ${DOCU_TARGET_PATH}${OPENMS_BUILDNAME_PREFIX}documentation/")
	execute_process(COMMAND
		cmake
		-E
		copy_directory
		${CTEST_BINARY_DIRECTORY}/doc/
		${DOCU_TARGET_PATH}${OPENMS_BUILDNAME_PREFIX}documentation/
		WORKING_DIRECTORY
		${CTEST_BINARY_DIRECTORY})

endmacro()

message(STATUS "Building Documentation")

# test again with new macro
ctest_test(BUILD "${CTEST_BINARY_DIRECTORY}")
