if [[ $1 =~ ^msvc-.*$ ]]
  then
    export VS_NR=${1/msvc-/}
    if (( VS_NR -lt 11 ))
      ((VS_YEAR=VS_NR+2000))
    else
      ((VS_YEAR=VS_NR+2001))
    fi
  export VS_YEAR
  export GENERATOR="Visual Studio ${VS_NR}${GENERATOR_ARCH_SUFFIX}"
  echo "Using GENERATOR=$GENERATOR"
else
  echo "Unsupported compiler $1 on windows."
fi
