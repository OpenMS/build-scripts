## replace OPENMS_SVN_DIR and CTEST_SOURCE_DIRECTORY with the appropriate values
## if the nightly builds need to be switched to release-branches

set(SCRIPT_PATH "/Users/aiche/NIGHTLY/scripts")

if(NOT DEFINED TEST_MACROS_INCLUDED)
  include( "${SCRIPT_PATH}/test_macros.cmake" )
endif()

# variables
SET (OPENMS_SVN_SERVER "https://open-ms.svn.sourceforge.net/svnroot/open-ms/")
SET (OPENMS_SVN_DIR "OpenMS")

#
SET (CTEST_SOURCE_DIRECTORY "/Users/aiche/NIGHTLY/RELEASE" )
SET (BUILD_DIRECTORY        "/Users/aiche/NIGHTLY/builds")

# general ctest/cmake/other programs
SET (CMAKE_BIN_PATH "/usr/local/bin/")
SET (CTEST_CMAKE_COMMAND   "${CMAKE_BIN_PATH}cmake")
SET (CTEST_CTEST_COMMAD "${CMAKE_BIN_PATH}ctest")
SET (CTEST_SVN_COMMAND   "/usr/bin/svn")
SET (CTEST_SVN_CHECKOUT  "${CTEST_SVN_COMMAND} co ${OPENMS_SVN_SERVER}${OPENMS_SVN_DIR} ${CTEST_SOURCE_DIRECTORY}")

# Qt stuff
SET (QT_QMAKE "/Users/aiche/dev/qt-4.8.4/bin/qmake")

# compiler versions
include( "${SCRIPT_PATH}/compilers.cmake" )

SET (SYSTEM_IDENTIFIER "mac-osx-10.8")

# contrib definitions
SET (OPENMS_CONTRIB "/Users/aiche/NIGHTLY/contrib/build/gcc")

SET (OPENMS_BUILDNAME_PREFIX "release1.10-")

SET (SEARCH_ENGINES_DIRECTORY "/Users/aiche/NIGHTLY/SEARCHENGINES")

# checker target settings
SET( PACKAGE_TARGET_PATH "/Volumes/ftp.mi.fu-berlin.de/pub/OpenMS/nightly_binaries")