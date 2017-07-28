if [[ $1 =~ ^msvc-.*$ ]]
then
  export VS_NR=${1/msvc-/}
  ## Works starting from VS2010
  if (( VS_NR < "11" ))
    then
    offset=0
  elif (( VS_NR < "15" ))
    then
    offset=1
  else
    offset=2
  fi
  ((VS_YEAR=VS_NR+2000+offset))
  export VS_YEAR
  export COMPILER_ID=$1
  
  export GENERATOR="Visual Studio ${VS_NR} ${VS_YEAR}${GENERATOR_ARCH_SUFFIX}"
  echo "Using GENERATOR=$GENERATOR"
else
  echo "Unsupported compiler $1 on windows."
fi
