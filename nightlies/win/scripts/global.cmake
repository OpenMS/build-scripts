## replace OPENMS_SVN_DIR and CTEST_SOURCE_DIRECTORY with the appropriate values
## if the nightly builds need to be switched to release-branches

##
set(SCRIPT_PATH "${CTEST_SCRIPT_DIRECTORY}")

if(NOT DEFINED TEST_MACROS_INCLUDED)
  include( "${SCRIPT_PATH}/selector.cmake" )
endif()

# variables
#SET (OPENMS_SVN_SERVER "https://open-ms.svn.sourceforge.net/svnroot/open-ms/")
# customize this to switch between head or a specific release
#SET (OPENMS_SVN_DIR "OpenMS")
# SET (OPENMS_SVN_DIR "OpenMS") ## the setting to test the head
set(CTEST_GIT_COMMAND "C:\Program Files (x86)\Git\bin\git.exe")
set(CTEST_UPDATE_COMMAND ${CTEST_GIT_COMMAND})

## Prefix for all builds (e.g., to distinguish between HEAD and Release-branch)
SET (OPENMS_BUILDNAME_PREFIX "")

## Path to a valid checkout corresponding to the above selected
## branch
SET (CTEST_SOURCE_DIRECTORY "C:/dev/NIGHTLY/OpenMS" )
## Path where the nightly builds will be build
SET (BUILD_DIRECTORY        "C:/dev/NIGHTLY/builds")

# Compiler Settings (see compilers.cmake in the example folder)
include( "compilers.cmake" )

# Describe your system as it will be shown in CDash
SET (SYSTEM_IDENTIFIER "win8")
SET (CTEST_SITE "scratchy.imp.fu-berlin.de")

set(CTEST_COMMAND "C:/Program Files/CMake/bin/ctest.exe")
set(CMAKE_COMMAND "C:/Program Files/CMake/bin/cmake.exe")