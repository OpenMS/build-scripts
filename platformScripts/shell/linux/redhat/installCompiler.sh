sudo yum -y install epel-release && sudo yum -y update >> $LOG_PATH/packages.log 2>&1
if [[ $1 =~ ^g++.*$ ]]
    then
    if [[ $(g++ -dumpversion) =~ ^.*"$1".*$ ]]
    then
        echo "$(g++ -dumpversion) already installed. Using this."
        export COMPILER_ID="g++-$(g++ -dumpversion)"
        export CXX=$(which g++)
        export CC=$(which gcc)
    else
        packageregex=${1/g/gcc-c}
        ## Careful: Maybe only take first match. Might install multiple versions, if version is not specific enough.
        sudo yum -y install "$packageregex*" >> $LOG_PATH/packages.log 2>&1
        if ! [[ -z $(g++ -dumpversion) ]]
        then
          export COMPILER_ID="g++-$(g++ -dumpversion)"
          export CXX=$(which g++)
          export CC=$(which gcc)
          echo "Installed $COMPILER_ID"
        else 
          echo "Installation of $1 failed. Check package name, repo settings/availability and the script $0."
        fi
    fi
elif [[ $1 =~ ^clang.*$ ]]
    then
    packageregex=$1
    ## Careful: Maybe only take first match. Might install multiple versions, if version is not specific enough.
    sudo yum -y install "$packageregex*" >> $LOG_PATH/packages.log 2>&1
    if ! [[ -z $(clang --version) ]]
    then
      ## clang version output is too different between distros. Just use what was given.
      echo "Installed:"
      clang --version
      
      export COMPILER_ID="$1"
      export CXX=$(which clang++)
      export CC=$(which clang)
    else
      echo "Installation of $1 failed. Check package name, repo settings/availability and the script $0."
    fi
else
   echo "Compiler $1 not supported on RedHat."
fi
