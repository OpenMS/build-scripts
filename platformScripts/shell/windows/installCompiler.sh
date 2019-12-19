function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }
if [[ $1 =~ ^msvc-.*$ ]]
then
  export VS_NR=${1/msvc-/}
  if [ $(version $VS_NR) -lt $(version "14.0") ]
    then
    echo "VS too old"
    exit 1
  elif [ $(version $VS_NR) -lt $(version "14.1") ]
    then
    export VS_NR=14
    VS_YEAR=2015
  elif [ $(version $VS_NR) -lt $(version "14.2") ]
    then
    export VS_NR=15
    VS_YEAR=2017
  elif [ $(version $VS_NR) -lt $(version "14.3") ]
    then
    export VS_NR=16
    VS_YEAR=2019
    # By default it builds for the current arch. Which is fine.
    # If we need to change it in the future we need to use the
    # -A option of CMake or better introduce CMake toolchain files
    # on each machine
    export GENERATOR_ARCH_SUFFIX=""
  fi
  ((VS_YEAR=VS_NR+2000+offset))
  export VS_YEAR
  export COMPILER_ID=$1
  
  export GENERATOR="Visual Studio ${VS_NR} ${VS_YEAR}${GENERATOR_ARCH_SUFFIX}"
  echo "Using GENERATOR=$GENERATOR"
else
  echo "Unsupported compiler $1 on windows."
fi
