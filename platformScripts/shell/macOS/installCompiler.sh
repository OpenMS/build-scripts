if [[ $1 =~ ^appleclang*$ ]]
  then
  sourceHere installCommandlineTools.sh
elif [[ $1 =~ ^g++*$ ]]
    then
    formulaname=${1/+/c}
    brew tap homebrew/versions
    brew install $formulaname
    if [[ -z $($1 -dumpversion) ]]
    then
      export COMPILER_ID="g++-$(g++ -dumpversion)"
      export CXX=$(which $1)
      export CC=$(which $formulaname)
      echo "Installed $COMPILER_ID"
    else
      echo "Compiler installation failed. Check package name, repo settings/availability and the script $0."    
    fi
elif [[ $1 =~ ^clang*$ ]]
    echo "Not supported yet"
    exit 1
else
    echo "Unsupported compiler on macOS. Aborting."
    exit 1
fi
    
