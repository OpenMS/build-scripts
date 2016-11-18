if [[ $1 =~ ^g++.*$ ]] 
  then
  sudo apt-get -y install $1
  ver=${1#*-}
  if ! [[ -z $($1 -dumpversion) ]]
  then
    export COMPILER_ID="g++-$($1 -dumpversion)"
    export CXX=$(which g++-$ver)
    export CC=$(which gcc-$ver)
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-$ver 100 --slave /usr/bin/g++ g++ /usr/bin/g++-$ver
    sudo update-alternatives --set gcc /usr/bin/gcc-$ver
    echo "Installed $COMPILER_ID"
  else
    echo "Compiler installation failed. Check package name, repo settings/availability and the script $0."
  fi
elif [[ $1 =~ ^clang.*$ ]]
  then
  sudo apt-get -y install $1
  ver=${1#*-}
  if ! [[ -z $($1 --version) ]]
  then
    echo "Installed:"
    clang++-$ver --version
    ## Outputs of clang version change on different distros. Just use what was given.
    export COMPILER_ID="$1"
    export CXX=$(which clang++-$ver)
    export CC=$(which clang-$ver)
  else
    echo "Compiler $1 not supported on Debian. Extend $0 , write your own installation routine or install beforehand."
  fi
else
   echo "Unsupported compiler on Debian."
fi
