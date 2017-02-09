## TODO make dependent on jenkins variable.
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

if [[ $OS_LABEL =~ ^win.*32$ ]]
  then
    export OPENMS_TARGET_ARCH=x86
  else
    export OPENMS_TARGET_ARCH=x64
fi

export OPENMS_TARGET_ARCH=$ARCH
export SUBDISTRO_VERSION=$(systeminfo | grep '^OS\ Name' | egrep -o "(XP|Vista|7|8|10)")
export SUBDISTRO_NAME="Windows"
## On Windows, only the visual studio version and the architecture should matter.
export REMOTE_CONTRIB_FOLDER="contrib/$OPSYS/$OPENMS_TARGET_ARCH/$COMPILER"
export CONTRIB_URL="https://abibuilder.informatik.uni-tuebingen.de/archive/openms/$REMOTE_CONTRIB_FOLDER/contrib_build.tar.gz"

## We need that wrapper for CMake to load all the correct environment variables. We could also replicate what the bat file does.
function runNative {
    eval vcpath="\$VS${VS_NR}0COMNTOOLS..\\\\..\\\\VC"
    vcpathcyg=$(cygpath -m "$vcpath")
    vssetup="$vcpathcyg/vcvarsall.bat"
    if [[ $DISTRO == "mingw" ]]
      then
        slashes="//"
      else
        slashes="/"
    fi
    echo Calling: cmd ${slashes}Q ${slashes}C call "$vssetup" "${OPENMS_TARGET_ARCH}" "&&" "${@}" 
    cmd ${slashes}Q ${slashes}C call "$vssetup" "${OPENMS_TARGET_ARCH}" "&&" "${@}"
}

