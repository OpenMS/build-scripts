if ! ([[ $1 =~ ^g++.*$ ]] || [[ $1 =~ ^clang.*$ ]])
  then
  echo "Compiler $1 not supported on RedHat. Extend $0 , write your own installation routine or install beforehand."
else
  if [[ $1 =~ ^g++.*$ ]]
    then
    packageregex=${1/g/gcc-c}
  fi
  if [[ $1 =~ ^clang.*$ ]]
    then
    packageregex=$1
  fi
  ## Careful: Maybe only take first match. Might install multiple versions, if version is not specific enough.
  sudo yum -y install "$packageregex*"

  if [[ -z $(g++ -dumpversion) ]]
  then
    export COMPILER_ID="g++-$(g++ -dumpversion)"
    export CXX=$(which g++)
    export CC=$(which gcc)
    echo "Installed $COMPILER_ID"
  else
    echo "Compiler installation failed. Check package name, repo settings/availability and the script $0."
fi
