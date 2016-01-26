## replace OPENMS_SVN_DIR and CTEST_SOURCE_DIRECTORY with the appropriate values
## if the nightly builds need to be switched to release-branches

set(SCRIPT_PATH "/group/ag_abi/OpenMS/nightly-builds/scripts")

include ( "${SCRIPT_PATH}/VirtualXServer.cmake" )

if(NOT DEFINED TEST_MACROS_INCLUDED)
  include( "${SCRIPT_PATH}/test_macros.cmake" )
endif()

# variables
set (OPENMS_SVN_SERVER "https://open-ms.svn.sourceforge.net/svnroot/open-ms/")
set (OPENMS_SVN_DIR "OpenMS")

#
set (CTEST_SOURCE_DIRECTORY "/group/ag_abi/OpenMS/nightly-builds/HEAD" )
set (BUILD_DIRECTORY        "/buffer/ag_abi/Nightly/openms")

# general ctest/cmake/other programs
set (CMAKE_BIN_PATH "/usr/bin/")
set (CTEST_CMAKE_COMMAND   "${CMAKE_BIN_PATH}cmake")
set (CTEST_CTEST_COMMAND "${CMAKE_BIN_PATH}ctest")
#set (CTEST_SVN_COMMAND   "/usr/bin/svn")
set (CTEST_GIT_COMMAND   "/usr/bin/git")
set (CTEST_UPDATE_COMMAND "${CTEST_GIT_COMMAND}")
#set (CTEST_SVN_CHECKOUT  "${CTEST_SVN_COMMAND} co ${OPENMS_SVN_SERVER}${OPENMS_SVN_DIR} ${CTEST_SOURCE_DIRECTORY}")

# Qt stuff
set (QT_QMAKE "/usr/bin/qmake")

# compiler versions
include( "${SCRIPT_PATH}/compilers.cmake" )

set (SYSTEM_IDENTIFIER "linux-3.2.41-2+deb7u2")

# contrib definitions
set (OPENMS_CONTRIB "/group/ag_abi/OpenMS/contrib/build/gcc")

set (OPENMS_BUILDNAME_PREFIX "")

# proxy settings
set( $ENV{http_proxy}    "http://http-proxy.fu-berlin.de/" )
set( $ENV{HTTP_PROXY}    "http://http-proxy.fu-berlin.de/" )

# checker target settings
set( CHECKER_TARGET_PATH "/web/ftp.mi.fu-berlin.de/pub/OpenMS/")
set( PACKAGE_TARGET_PATH "/web/ftp.mi.fu-berlin.de/pub/OpenMS/nightly_binaries/")
set( DOCU_TARGET_PATH    "/web/ftp.mi.fu-berlin.de/pub/OpenMS/")

set (CTEST_CHECK_HTTP_ERROR ON)
