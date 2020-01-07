## Legacy. This is how you get the actual host architecture.
## But we read from Jenkins variable to be able to cross-compile
#if [[ -z $(wmic OS get OSArchitecture | grep "64-bit") ]]
if [[ $OS_LABEL =~ ^win.*32$ ]]
then
  export ARCH=x86
  export CMAKE_ARCH_NAME=Win32
  export OPENMS_TARGET_ARCH=x86
  export VS_WHERE_ARCH=x86
  export ARCH_NO_BIT=32
else
  export ARCH=x64
  export CMAKE_ARCH_NAME=x64
  export OPENMS_TARGET_ARCH=x64
  export VS_WHERE_ARCH=amd64
  export ARCH_NO_BIT=64
fi

export SUBDISTRO_VERSION=$(systeminfo | egrep -o '^(OS\ Name|Betriebssystemname).*' | egrep -o "(XP|Vista|7|8|10)")
export SUBDISTRO_NAME="Windows"
## On Windows, only the visual studio version and the architecture should matter.
export REMOTE_CONTRIB_FOLDER="contrib/$OPSYS/$OPENMS_TARGET_ARCH/$COMPILER"
export CONTRIB_URL="https://abibuilder.informatik.uni-tuebingen.de/archive/openms/$REMOTE_CONTRIB_FOLDER/contrib_build.tar.gz"

## If the CMAKE variable is set, e.g. in Jenkins config, we add this to the path to choose the correct cmake
if [ ! -z "$CMAKE" ]
then
  export PATH=$CMAKE:$PATH
fi
## Only needed on Windows to escape C: when using tar. Only supported by gnutar. Not usable on Mac.
export force_local_flag=--force-local

## We need that wrapper for CMake to load all the correct environment variables. We could also replicate what the bat file does.
function runNative {
    ## Starting from VS2017 MS will have vswhere in a certain path. No env vars.
    if (( VS_NR < "15" ))
      then
      eval vcpath="\$VS${VS_NR}0COMNTOOLS..\\\\..\\\\VC"
      vcpathcyg=$(cygpath -m "$vcpath")
      vssetup="\"$vcpathcyg/vcvarsall.bat\""
      varsetupcommand="$vssetup ${OPENMS_TARGET_ARCH}"
    else
      vcpath=$("$PROGRAMFILES/Microsoft Visual Studio/Installer/vswhere" -all -property installationPath)
       if [ -z "$vcpath" ]
       then
         ## If vcpath still empty, it was installed to x86 folder
         ## Git bash cannot access the ProgramFiles(x86) variable because of the invalid characters
         ## So we hope that the x86 folder is as usual just appended with " (x86)"
         vcpath=$("$PROGRAMFILES (x86)/Microsoft Visual Studio/Installer/vswhere" -all -property installationPath | grep $VS_YEAR)
       fi

      vcpathcyg=$(cygpath -m "$vcpath")/Common7/Tools
      vssetup="\"$vcpathcyg/VsDevCmd.bat\" -arch=${VS_WHERE_ARCH}"
      varsetupcommand=$vssetup
    fi
    
    ## In MinGW/Git for Windows the slashes need to be escaped additionally
    ## Not for cygwin
    if [[ $DISTRO == "mingw" ]]
      then
        slashes="//"
      else
        slashes="/"
    fi
    ## Be careful. Might suffer from "Input line too long" problem if the CMake command is too long.
    ## Did not happen yet.
    echo Calling: cmd ${slashes}Q ${slashes}C \"call\" "$varsetupcommand" "&&" "${@}"
    ##${slashes}Q ${slashes}C
    cmd << EOD
call $varsetupcommand
${@}
exit /b %errorlevel%
EOD
}

