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
## On Windows, only the visual studio version and the architecture should matter.
export REMOTE_CONTRIB_FOLDER="contrib/$OPSYS/$TARGET_ARCH/$COMPILER"
export CONTRIB_URL="https://abibuilder.informatik.uni-tuebingen.de/archive/openms/$REMOTE_CONTRIB_FOLDER/contrib_build.tar.gz"

## We need that wrapper for CMake to load all the correct environment variables. We could also replicate what the bat file does.
function runNative {
    eval vssetup="\$VS${VS_NR}0COMNTOOLS\\vsvarsall.bat ${TARGET_ARCH}"
    cmd /Q /C call "$vssetup" "&&" "${@}"
}

