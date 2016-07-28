# customize error reporting on cdash

# ------------------------------------------------------------
# Increase number of reported errors/warnings.
# ------------------------------------------------------------

## customize reporting of errors in CDash
set(CTEST_CUSTOM_MAXIMUM_NUMBER_OF_ERRORS 10000)
set(CTEST_CUSTOM_MAXIMUM_NUMBER_OF_WARNINGS 10000)

# ------------------------------------------------------------
# Suppress certain warnings.
# ------------------------------------------------------------

# Of course, the following list should be kept as short as possible and should
# be limited to very small lists of system/compiler pairs.  However, some
# warnings cannot be suppressed from the source.  Also, the warnings
# suppressed here should be specific to certain system/compiler versions.
# If you add anything then document what it does.

set (CTEST_CUSTOM_WARNING_EXCEPTION
    # Suppress warnings imported from boost
    ".include/boost.*:.*"
    ".*boost_static_assert_typedef_575.*"
    ".*boost_static_assert_typedef_628.*"
    ".*BOOST_STATIC_ASSERT.*"
    # Suppress warnings imported from seqan
    ".include/seqan.*:.*"
    ".*seqan.*[-Wunused-local-typedefs]"
    ".*qsharedpointer_impl.h:595:43.*"
    # From old scripts
    ".*/contrib/build/[^/]+/include/.*$"
    )

set(CTEST_CUSTOM_ERROR_EXCEPTION
        "^.*QcMLFile: errorString.*$"
        "^.*QcMLFile: error.*$")



