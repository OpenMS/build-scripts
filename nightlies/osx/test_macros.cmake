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

set(TEST_MACROS_INCLUDED On)
set(TEST_MACROS_DEBUG On)

message(${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME})

# CTest 2.6 crashes with message() after ctest_test.
macro(safe_message)
	if(NOT "${CMAKE_VERSION}" VERSION_LESS 2.8 OR NOT safe_message_skip)
		message(${ARGN})
	endif()
endmacro()

# checks for a given list of variables if they are defined
# and backs up the current values, so they can later be restored
# if they were modified
macro(backup_and_check_variables variable_list)
	foreach(req IN LISTS ${variable_list})
		if(NOT DEFINED ${req})
			message(FATAL_ERROR "The containing script must set ${req}")
		else()
			set(${req}_BACKUP "${${req}}")
		endif()
	endforeach()
endmacro()

# restores all variables from the list given an backup value exists
macro(restore_variables variable_list)
	foreach(req IN LISTS ${variable_list})
		if(NOT DEFINED ${req}_BACKUP)
			safe_message(FATAL_ERROR
				"Failed to restore variable ${req} from ${req}_BACKUP")
		else()
			set(${req} "${${req}_BACKUP}")
			if(TEST_MACROS_DEBUG)
				safe_message("restored ${req} -> ${${req}}")
			endif()
		endif()
	endforeach()
endmacro()

macro(select_compiler compiler_prefix)
	safe_message("Selecting compiler: ${compiler_prefix}")
	set(compiler_variables
		"COMPILER_IDENTIFIER;C_COMPILER;CXX_COMPILER;GENERATOR;OPENMS_CONTRIB")
	foreach(compiler_variable IN LISTS compiler_variables)
		if(DEFINED ${compiler_prefix}_${compiler_variable})
			if(TEST_MACROS_DEBUG)
				safe_message("Setting ${compiler_variable} -> ${${compiler_prefix}_${compiler_variable}}")
			endif()
			set(${compiler_variable}
				"${${compiler_prefix}_${compiler_variable}}")
		else()
			safe_message(FATAL_ERROR "No compiler ${compiler_prefix} found")
		endif()
	endforeach()
endmacro()

macro(prepare_notes)
	list(APPEND
		CTEST_NOTES_FILES
		"${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}"
		"${CTEST_SCRIPT_DIRECTORY}/global.cmake"
		"${SCRIPT_PATH}/test_macros.cmake")
endmacro()

macro(run_tests)
	include(${SCRIPT_PATH}/run_tests.cmake)
endmacro()
