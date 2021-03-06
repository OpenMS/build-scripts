## TODO set Generator here and check if xcode is wanted.

if [[ $1 =~ ^appleclang.*$ ]]
  then
  export COMPILER_ID="$1"
  # We do not use the full paths, because the wrappers under
  # /usr/bin/ always have the correct sysroot paths included.
  # Use xcode-select if you want to switch to another installed appleclang.
  #export CXX=$(which clang++)
  #export CC=$(which clang)
  export CXX=/usr/bin/clang++
  export CC=/usr/bin/clang
  
  # For now only Unix Makefiles are supported. XCode should be not much work though.
  export GENERATOR="Unix Makefiles"
  ## If you have multiple compilers installed you should set a correct
  ## sysroot to find the right stdlibs for example. Not necessary for now.
  #if [[ -n ${SYSROOT+x} ]]
  #  then
  #  export ADDITIONAL_CMAKE_ARGUMENTS="${ADDITIONAL_CMAKE_ARGUMENTS-} -DCMAKE_OSX_SYSROOT=${SYSROOT-}"
  #else
  #  export ADDITIONAL_CMAKE_ARGUMENTS="${ADDITIONAL_CMAKE_ARGUMENTS-}"
  #fi
  echo "Installed $COMPILER_ID"
elif [[ $1 =~ ^g\+\+.*$ ]]
    then
    ## TODO formula name is actually something like gcc48
    ## assume installed for now
    #formulaname=${1/+/c}
    #brew tap homebrew/versions >> $LOG_PATH/packages.log 2>&1
    #brew install $formulaname >> $LOG_PATH/packages.log 2>&1
    if ! [[ -z $($1 -dumpversion) ]]
    then
      export COMPILER_ID="g++-$($1 -dumpversion)"
      export CXX=$(which $1)
      export CC=$(which ${1/++/cc})
      echo CC
      export GENERATOR="Unix Makefiles"
      ## TODO probably not gonna work. I think you NEED the command line tools then
      ## Yes, let's try without.
      ##export ADDITIONAL_CMAKE_ARGUMENTS="-DCMAKE_OSX_SYSROOT=$SYSROOT"
      echo "Installed $COMPILER_ID"
    else
      echo "Compiler installation of $1 failed. Check package name, repo settings/availability and the script $0."    
    fi
elif [[ $1 =~ ^clang.*$ ]]
    then
    ## TODO check how to set CXX and CC so that the right clang is used.
    echo "Not supported yet"
    exit 1
else
    echo "Unsupported compiler $1 on macOS. Aborting."
    exit 1
fi
    
