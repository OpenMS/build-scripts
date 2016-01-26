# customize error reporting on cdash

set(CTEST_CUSTOM_ERROR_EXCEPTION
        "^.*QcMLFile: errorString.*$"
        "^.*QcMLFile: error.*$")

set(CTEST_CUSTOM_WARNING_EXCEPTION
  ${CTEST_CUSTOM_WARNING_EXCEPTION}
  ".*/contrib/build/[^/]+/include/.*$"
)



