MACRO(START_XSERVER XSERVER_DISPLAY)
  find_program(PROGRAM_XVNC "Xvnc_runner" HINTS ${SCRIPT_PATH})
	if (NOT PROGRAM_XVNC)
		MESSAGE(FATAL_ERROR "Cannot find 'Xvnc_runner' on your system. Please install Xvnc_runner and add the directory to your PATH environment variable!")
	endif()
  
  execute_process(
    COMMAND ${PROGRAM_XVNC} start
    OUTPUT_VARIABLE _xserver_display
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  
  SET (ENV{DISPLAY} ":${_xserver_display}")
  SET (XSERVER_DISPLAY ${_xserver_display})
ENDMACRO(START_XSERVER)

MACRO(RESTART_XSERVER XSERVER_DISPLAY)
  execute_process(
    COMMAND ${PROGRAM_XVNC} restart ${XSERVER_DISPLAY}
  )
ENDMACRO(RESTART_XSERVER)

MACRO(KILL_XSERVER XSERVER_DISPLAY)
  execute_process(
    COMMAND ${PROGRAM_XVNC} stop ${XSERVER_DISPLAY}
  )
ENDMACRO(KILL_XSERVER)
