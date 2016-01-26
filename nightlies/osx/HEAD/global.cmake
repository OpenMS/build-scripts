## replace OPENMS_SVN_DIR and CTEST_SOURCE_DIRECTORY with the appropriate values
## if the nightly builds need to be switched to release-branches

set(SCRIPT_PATH "/Users/aiche/NIGHTLY/scripts")

if(NOT DEFINED TEST_MACROS_INCLUDED)
  include( "${SCRIPT_PATH}/test_macros.cmake" )
endif()

# variables
set (OPENMS_SVN_SERVER "https://open-ms.svn.sourceforge.net/svnroot/open-ms/")
set (OPENMS_SVN_DIR "OpenMS")

#
set (CTEST_SOURCE_DIRECTORY "/Users/aiche/NIGHTLY/HEAD" )
set (BUILD_DIRECTORY        "/Users/aiche/NIGHTLY/builds")

# general ctest/cmake/other programs
set (CMAKE_BIN_PATH "/usr/local/bin/")
set (CTEST_CMAKE_COMMAND   "${CMAKE_BIN_PATH}cmake")
set (CTEST_CTEST_COMMAD "${CMAKE_BIN_PATH}ctest")
set (CTEST_GIT_COMMAND   "/usr/local/bin/git")
set (CTEST_UPDATE_COMMAND "${CTEST_GIT_COMMAND}")

# Qt stuff
set (QT_QMAKE "/usr/local/bin/qmake")

# compiler versions
include( "${SCRIPT_PATH}/compilers.cmake" )

set (SYSTEM_IDENTIFIER "mac-osx-10.8")

# contrib definitions
#set (OPENMS_CONTRIB "/Users/aiche/NIGHTLY/contrib/build/clang")

set (OPENMS_BUILDNAME_PREFIX "")

# checker target settings
#set( CHECKER_TARGET_PATH "/web/ftp.mi.fu-berlin.de/pub/OpenMS/")
#set( PACKAGE_TARGET_PATH "/web/ftp.mi.fu-berlin.de/pub/OpenMS/nightly_binaries/")
#set( DOCU_TARGET_PATH    "/web/ftp.mi.fu-berlin.de/pub/OpenMS/")
