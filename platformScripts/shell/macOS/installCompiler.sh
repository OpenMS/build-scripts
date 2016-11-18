## TODO set Generator here and check if xcode is wanted.
if [[ $1 =~ ^appleclang.*$ ]]
  then
  sourceHere installCommandlineTools.sh
  export COMPILER_ID="$1"
  export CXX=$(which clang++)
  export CC=$(which clang)
  export GENERATOR="Unix Makefiles"
  export ADDITIONAL_CMAKE_ARGUMENTS="-DCMAKE_OSX_SYSROOT=$SYSROOT"
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
      export CC=$(which ${1/\+/c})
      export GENERATOR="Unix Makefiles"
      ## TODO probably not gonna work. I think you NEED the command line tools then
      export ADDITIONAL_CMAKE_ARGUMENTS="-DCMAKE_OSX_SYSROOT=$SYSROOT"
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
    
