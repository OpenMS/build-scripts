## CMake Nightly Build Macros for all platforms
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

##http://stackoverflow.com/questions/7787823/cmake-how-to-get-the-name-of-all-subdirectories-of-a-directory
##Gets all subdirectories of a folder
MACRO(SUBDIRLIST result curdir)
  FILE(GLOB children RELATIVE ${curdir} ${curdir}/*)
  SET(dirlist "")
  FOREACH(child ${children})
    IF(IS_DIRECTORY ${curdir}/${child})
        LIST(APPEND dirlist ${child})
    ENDIF()
  ENDFOREACH()
  SET(${result} ${dirlist})
ENDMACRO()

## !!! For Unix builds only
#if(UNIX)
#  include(${CTEST_SCRIPT_DIRECTORY}/unix_macros.cmake)
#endif(UNIX)

## !!! For Win builds only (includes correct selection and setting of Searchengine paths)
#if(WIN32)
#  include(${CTEST_SCRIPT_DIRECTORY}/win_macros.cmake)
#endif(WIN32)
###

macro(prepare_notes)
  list(APPEND CTEST_NOTES_FILES
    "${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}"
    "${SCRIPT_PATH}/global_macros.cmake"
  )
endmacro(prepare_notes)

macro(backup_test_results backupdir_prefix)
  safe_message("Backing up test results. Adding prefix ${backupdir_prefix}.")
  file(COPY ${CTEST_BINARY_DIRECTORY}\Testing DESTINATION ${CTEST_BINARY_DIRECTORY}\${backupdir_prefix}_Testing)
endmacro(backup_test_results)

macro(run_tests)
  safe_message("Starting tests!!")
  include ( ${SCRIPT_PATH}/run_tests.cmake)
endmacro()

macro(run_tests_from_config)
  safe_message("Starting tests!!")
  include ( ${SCRIPT_PATH}/run_tests_with_config.cmake)
endmacro()
