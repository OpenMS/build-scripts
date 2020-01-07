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
  fi
  export VS_YEAR
  export COMPILER_ID=$1
  
  export GENERATOR="Visual Studio ${VS_NR} ${VS_YEAR}"
  export ADDITIONAL_CMAKE_ARGUMENTS="${ADDITIONAL_CMAKE_ARGUMENTS-} -A ${CMAKE_ARCH_NAME}"
  echo "Using GENERATOR=$GENERATOR with ADDITIONAL_CMAKE_ARGUMENTS=$ADDITIONAL_CMAKE_ARGUMENTS"
else
  echo "Unsupported compiler $1 on windows."
fi
