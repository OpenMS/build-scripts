## CMake Nightly Build Scripts for Windows
## (c) 2013 Stephan Aiche

set(TEST_MACROS_INCLUDED On)

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

# checks if all the variables defined in @p variable_list
# are set
macro(check_variables variable_list)
  foreach(req IN LISTS ${variable_list})
     if(NOT DEFINED ${req})
       message(FATAL_ERROR "The containing script must set ${req}")
     endif()
   endforeach()
endmacro()

# restores all variables from the list given an backup value exists
macro(restore_variables variable_list)
	foreach(req IN LISTS ${variable_list})
		if(NOT DEFINED ${req}_BACKUP)
			safe_message(FATAL_ERROR "Failed to restore variable ${req} from ${req}_BACKUP")
		else()
			set(${req} "${${req}_BACKUP}")
			if(TEST_MACROS_DEBUG)
				safe_message("restored ${req} -> ${${req}}")
			endif(TEST_MACROS_DEBUG)
		endif()
	endforeach()
endmacro()

macro(select_vs_version version arch)
	set(vs_variables "CONTRIB;QT;GENERATOR")
	set(compiler_prefix "${version}_${arch}")
  foreach(vs_var IN LISTS vs_variables)
    if(DEFINED ${compiler_prefix}_${vs_var})
      if(TEST_MACROS_DEBUG)
        safe_message("Setting ${vs_var} -> ${${compiler_prefix}_${vs_var}}")        
      endif(TEST_MACROS_DEBUG)
      set( ${vs_var} "${${compiler_prefix}_${vs_var}}")
    else()
      safe_message(FATAL_ERROR "No compiler ${compiler_prefix} found")
    endif()  
  endforeach()
	
	set(arch_variables "MYRIMATCH_PATH;OMSSA_PATH;XTANDEM_PATH")
	foreach(arch_var IN LISTS arch_variables)
		if(DEFINED ${arch}_${arch_var})
			set( ${arch_var} "${${arch}_${arch_var}}")
		else()
			safe_message(FATAL_ERROR "Missing ${arch_var} for architecture ${arch}")
		endif()
	endforeach()
endmacro()

macro(prepare_notes)
  list(APPEND CTEST_NOTES_FILES
    "${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}"
    "${CTEST_SCRIPT_DIRECTORY}/global.cmake"
    "${SCRIPT_PATH}/test_macros.cmake"
  )
endmacro(prepare_notes)

macro(run_nightly)
	safe_message("Starting tests!!")
  include ( ${SCRIPT_PATH}/run_tests.cmake)
endmacro()