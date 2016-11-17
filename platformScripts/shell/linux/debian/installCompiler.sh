if [[ $1 =~ ^g++.*$ ]] 
  then
  sudo apt-get -y install $1
  if ! [[ -z $(g++ -dumpversion) ]]
  then
    export COMPILER_ID="g++-$(g++ -dumpversion)"
    export CXX=$(which g++)
    export CC=$(which gcc)
    echo "Installed $COMPILER_ID"
  else
    echo "Compiler installation failed. Check package name, repo settings/availability and the script $0."
  fi
elif [[ $1 =~ ^~clang.*$ ]]
  then
  sudo apt-get -y install $1
  if ! [[ -z $(clang++ --version) ]]
  then
    echo "Installed:"
    clang++ --version
    ## Outputs of clang version change on different distros. Just use what was given.
    export COMPILER_ID="$1"
    export CXX=$(which clang++)
    export CC=$(which clang)
  else
    echo "Compiler $1 not supported on Debian. Extend $0 , write your own installation routine or install beforehand."
  fi
else
   echo "Unsupported compiler on Debian."
fi
