
include ( /group/ag_abi/OpenMS/nightly-builds/scripts/HEAD/global.cmake ) 

START_XSERVER(XSERVER_DISPLAY)
MESSAGE( "Display is ${XSERVER_DISPLAY}")
KILL_XSERVER(${XSERVER_DISPLAY})
#execute_process(
#     COMMAND cat docu.cmake
#     OUTPUT_VARIABLE _RES
#)
#
#message(${_RES})
