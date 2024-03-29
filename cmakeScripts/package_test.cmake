# Check for required variables.
## TODO THIRDPARTY_ROOT could theoretically be made optional. Ships without thirdparty then.
set(required_variables "CTEST_SOURCE_DIRECTORY;CTEST_BINARY_DIRECTORY;INITIAL_CACHE;CTEST_BUILD_NAME")

backup_and_check_variables(required_variables)

if(NOT DEFINED CDASH_SUBMIT)
    set(CDASH_SUBMIT Off)
endif()

## TODO this variable is currently not passed from the parent script. Need to FIX
if(NOT DEFINED DASHBOARD_MODEL)
    set(DASHBOARD_MODEL Experimental)
endif()

SET (CTEST_BUILD_NAME "${CTEST_BUILD_NAME}_Package")

if(WIN32)
    set ( MY_PACK_TYPE "nsis")
elseif(APPLE)
    set ( MY_PACK_TYPE "dmg")
elseif(UNIX)
    if(EXISTS "/etc/debian_version")
        set ( MY_PACK_TYPE "deb")
    elseif(EXISTS "/etc/redhat-release")
        set ( MY_PACK_TYPE "rpm")
    else()
        safe_message(FATAL_ERROR "Could not determine Linux distribution to determine package type. No /etc/debian_version or redhat-release.")
    endif()
else()
    safe_message(FATAL_ERROR "Unknown platform. None of the CMAKE variables WIN32, APPLE, UNIX set.")
endif()

message("Starting package build:")
# build the package and submit the results to cdash  
CTEST_START   (${DASHBOARD_MODEL} TRACK Package)
# In version 3.1.0, CTEST_UPDATE_VERSION_ONLY was introduced.
# With this we can use the Jenkins Git plugin for the checkout and only get the version for CDash 
# Otherwise skip update completely
if(NOT "${CMAKE_VERSION}" VERSION_LESS 3.1.0)
   SET(CTEST_UPDATE_VERSION_ONLY On)
   CTEST_UPDATE(SOURCE "${CTEST_SOURCE_DIRECTORY}")
endif()

CTEST_CONFIGURE(OPTIONS "-DPACKAGE_TYPE=${MY_PACK_TYPE};-DSEARCH_ENGINES_DIRECTORY=$ENV{SEARCH_ENGINES_DIRECTORY};-DSIGNING_IDENTITY=$ENV{SIGNING_IDENTITY};-DSIGNING_EMAIL=$ENV{SIGNING_EMAIL}" RETURN_VALUE _reconfig_package_ret_val)

# The preinstall target that is called by "make package" will build the ALL target which includes
# doc and doc_tutorial (if enabled)
#CTEST_BUILD    (TARGET doc)
#CTEST_BUILD    (TARGET doc_tutorials APPEND)
if (APPLE AND "${CMAKE_VERSION}" VERSION_LESS 3.5)
  set(PACKAGE_TARGET "finalized_dist")
else()
  if(WIN32)
    set(PACKAGE_TARGET "signed_dist")
  else()
    set(PACKAGE_TARGET "dist")
  endif()
endif()
CTEST_BUILD(TARGET ${PACKAGE_TARGET} APPEND NUMBER_ERRORS _package_build_errors)

if(CDASH_SUBMIT)
    CTEST_SUBMIT  (PARTS Build)
endif()

restore_variables(required_variables)

# indicate errors
if(${_package_build_errors} GREATER 0 OR NOT ${_reconfig_package_ret_val} EQUAL 0)
  file(WRITE "${CTEST_BINARY_DIRECTORY}/package_failed" "package_failed")
endif()
