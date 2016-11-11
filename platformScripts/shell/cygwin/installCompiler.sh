if [[ $1 =~ ^msvc-.*$ ]]
  then
    export VS_NR=${1/msvc-/}
    if (( VS_NR -lt 11 ))
      export ((VS_YEAR=VS_NR+2000))
    else
      export ((VS_YEAR=VS_NR+2001))
    fi
  export GENERATOR="Visual Studio ${VS_NR}${GENERATOR_ARCH_SUFFIX}"
else
  echo "Unsupported compiler $1 on windows."
fi
