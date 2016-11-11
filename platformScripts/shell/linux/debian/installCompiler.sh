if ! ([[ $1 =~ ^g++.*$ ]] || [[ $1 =~ ^clang.*$ ]])
  then
  echo "Compiler $1 not supported on Debian. Extend $0 , write your own installation routine or install beforehand."
else
  sudo apt-get -y install $1
  if [[ -z $(g++ -dumpversion) ]]
  then
    export COMPILER_ID="g++-$(g++ -dumpversion)"
    export CXX=$(which g++)
    export CC=$(which gcc)
    echo "Installed $COMPILER_ID"
  else
    echo "Compiler installation failed. Check package name, repo settings/availability and the script $0."
fi
