## general purpose nightly testing script for OpenMS
CMAKE_MINIMUM_REQUIRED (VERSION 2.6)

# include general stuff
include ( /group/ag_abi/OpenMS/nightly-builds/scripts/RELEASE_BRANCH/global.cmake ) 

# set variables describing the build
SET (CTEST_SITE       "knecht.imp.fu-berlin.de")
SET (CTEST_BUILD_NAME "${OPENMS_BUILDNAME_PREFIX}linux-2.6.32-5-bpo.2-amd64-gcc-4.4.5-8-release")

# set variables describing the build environments
SET (CTEST_BINARY_DIRECTORY "/group/ag_abi/OpenMS/nightly-builds/builds/RELEASE_BRANCH-knecht_gcc-64bit-release")
SET (CTEST_BINARY_TEST_DIRECTORY "${CTEST_BINARY_DIRECTORY}/source/TEST/")

# define generator
SET (CTEST_CMAKE_GENERATOR "Unix Makefiles" )

# clear the binary directory to avoid problems
CTEST_EMPTY_BINARY_DIRECTORY (${CTEST_BINARY_DIRECTORY})

SET(INITIAL_CACHE "
CMAKE_FIND_ROOT_PATH:PATH=${OPENMS_CONTRIB}
CMAKE_BUILD_TYPE:STRING=Release
CMAKE_GENERATOR:INTERNAL=Unix Makefiles
QT_QMAKE_EXECUTABLE:FILEPATH=${OPENMS_QT47_QMAKE}
SVNCOMMAND:FILEPATH=${CTEST_SVN_COMMAND}
SVNVERSION_EXECUTABLE:FILEPATH=${CTEST_SVN_COMMAND}version
MAKECOMMAND:STRING=/usr/bin/make -i -j10
")

# this is the initial cache to use for the binary tree, be careful to escape
# any quotes inside of this string if you use it
FILE(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${INITIAL_CACHE})

# customizing PATH so ExecutePipeline_test finds its executables
set(ENV{PATH} "${CTEST_BINARY_DIRECTORY}/bin:$ENV{PATH}")

# start virtual xserver (Xvnc) to test TOPPView
START_XSERVER(DISPLAY)

# do the dashboard/testings steps
CTEST_START     (Nightly)
CTEST_UPDATE    (SOURCE "${CTEST_SOURCE_DIRECTORY}")
CTEST_CONFIGURE (BUILD "${CTEST_BINARY_DIRECTORY}")
CTEST_BUILD     (BUILD "${CTEST_BINARY_DIRECTORY}" APPEND)
CTEST_BUILD     (BUILD "${CTEST_BINARY_TEST_DIRECTORY}" APPEND) # build the tests
CTEST_TEST      (BUILD "${CTEST_BINARY_DIRECTORY}")
CTEST_SUBMIT    ()

include ( /group/ag_abi/OpenMS/nightly-builds/scripts/checker.cmake )

message (STATUS "Running on $DISPLAY")

#ensure that X is running
include ( /group/ag_abi/OpenMS/nightly-builds/scripts/docu.cmake )

#KILL_XSERVER(${DISPLAY})
