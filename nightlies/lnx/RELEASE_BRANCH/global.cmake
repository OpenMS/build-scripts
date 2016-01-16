## replace OPENMS_SVN_DIR and CTEST_SOURCE_DIRECTORY with the appropriate values
## if the nightly builds need to be switched to release-branches

set(SCRIPT_PATH "/group/ag_abi/OpenMS/nightly-builds/scripts")

include ( "${SCRIPT_PATH}/VirtualXServer.cmake" )

if(NOT DEFINED TEST_MACROS_INCLUDED)
  include( "${SCRIPT_PATH}/test_macros.cmake" )
endif()

# variables
SET (OPENMS_SVN_SERVER "https://open-ms.svn.sourceforge.net/svnroot/open-ms/")
SET (OPENMS_SVN_DIR "OpenMS")

#
SET (CTEST_SOURCE_DIRECTORY "/group/ag_abi/OpenMS/nightly-builds/RELEASE_BRANCH") 
SET (BUILD_DIRECTORY        "/group/ag_abi/OpenMS/nightly-builds/builds")

# general ctest/cmake/other programs
SET (CMAKE_BIN_PATH "/home/takifugu/aiche/local/bin/")
SET (CTEST_CMAKE_COMMAND   "${CMAKE_BIN_PATH}cmake")
SET (CTEST_CTEST_COMMAD "${CMAKE_BIN_PATH}ctest")
SET (CTEST_SVN_COMMAND   "/home/takifugu/aiche/local/bin/svn")
SET (CTEST_SVN_CHECKOUT  "${CTEST_SVN_COMMAND} co ${OPENMS_SVN_SERVER}${OPENMS_SVN_DIR} ${CTEST_SOURCE_DIRECTORY}")

# Qt stuff
SET (QT_QMAKE "/group/ag_abi/OpenMS/Qt/qt-4.7.4-gcc4.4.5/bin/qmake")

# compiler versions
include( "${SCRIPT_PATH}/compilers.cmake" )

SET (SYSTEM_IDENTIFIER "linux-2.6.32-5-amd64")

# contrib definitions
SET (OPENMS_CONTRIB "/group/ag_abi/OpenMS/contrib-build-gcc4.4.5/")

SET (OPENMS_BUILDNAME_PREFIX "release1.10-")

# proxy settings
SET( $ENV{http_proxy}    "http://http-proxy.fu-berlin.de/" )
SET( $ENV{HTTP_PROXY}    "http://http-proxy.fu-berlin.de/" )

# checker target settings
SET( CHECKER_TARGET_PATH "/web/ftp.mi.fu-berlin.de/pub/OpenMS/")
SET( PACKAGE_TARGET_PATH "/web/ftp.mi.fu-berlin.de/pub/OpenMS/nightly_binaries/")
SET( DOCU_TARGET_PATH    "/web/ftp.mi.fu-berlin.de/pub/OpenMS/")

SET (CTEST_CHECK_HTTP_ERROR ON)
