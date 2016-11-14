if [[ -z $(wmic OS get OSArchitecture | grep "64-bit") ]]
  then
  export ARCH=x86
  export ARCH_NO_BIT=32
  export GENERATOR_ARCH_SUFFIX=""
else
  export ARCH=x64
  export ARCH_NO_BIT=64
  export GENERATOR_ARCH_SUFFIX=" Win64"
fi

export SUBDISTRO_VERSION=$(systeminfo | grep '^OS\ Name' | egrep -o "(XP|Vista|7|8|10)")

