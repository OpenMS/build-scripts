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
     safe_message(FATAL_ERROR "Failed to restore variable ${req} from ${req}_BACKUP")
   else()
     set(${req} "${${req}_BACKUP}")
     if(TEST_MACROS_DEBUG)
       safe_message("restored ${req} -> ${${req}}")
     endif(TEST_MACROS_DEBUG)
   endif()
 endforeach()
endmacro()

macro(select_compiler compiler_prefix)
  safe_message("Selecting compiler: ${compiler_prefix}")
  set(compiler_variables "COMPILER_IDENTIFIER;C_COMPILER;CXX_COMPILER")
  foreach(compiler_variable IN LISTS compiler_variables)
    if(DEFINED ${compiler_prefix}_${compiler_variable})
      if(TEST_MACROS_DEBUG)
        safe_message("Setting ${compiler_variable} -> ${${compiler_prefix}_${compiler_variable}}")
      endif(TEST_MACROS_DEBUG)
      set( ${compiler_variable} "${${compiler_prefix}_${compiler_variable}}")
    else()
      safe_message(FATAL_ERROR "No compiler ${compiler_prefix} found")
    endif()
  endforeach()
endmacro(select_compiler compiler_prefix)

macro(prepare_notes)
  list(APPEND CTEST_NOTES_FILES
    "${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}"
    "${CTEST_SCRIPT_DIRECTORY}/global.cmake"
    "${SCRIPT_PATH}/test_macros.cmake"
  )
endmacro(prepare_notes)

macro(run_tests)
  include ( ${SCRIPT_PATH}/run_tests.cmake)
endmacro()