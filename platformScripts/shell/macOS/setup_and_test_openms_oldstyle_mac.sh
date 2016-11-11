function tick {
  start=`date +%s`
}

function tock {
  if [ -z ${start+x} ]
  then 
    echo "tick was not called before tock."
  else
    end=`date +%s`
    runtime=$((end-start))
    echo $runtime
  fi
}

# Rough check of the setup
mkdir $LOG_PATH
mkdir $BUILD_PATH
mkdir $INSTALL_PATH

#http://apple.stackexchange.com/questions/107307/how-can-i-install-the-command-line-tools-completely-from-the-command-line
## install xcode command-line-tools (clang, make, svn) with something like below.
#sudo xcode-select --install
#sleep 1
#osascript <<EOD
#  tell application "System Events"
#    tell process "Install Command Line Developer Tools"
#      keystroke return
#      click button "Agree" of window "License Agreement"
#    end tell
#  end tell
#EOD

## Accept license agreement
#sudo xcodebuild -license

## Install homebrew
#/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

## Scripting tools
# brew install wget coreutils
##Maybe set paths to new coreutils (the ones you need)

## Contrib build tools
# brew install cmake autoconf automake 
## Notes: in comparison to Linux, the brew CMake is usually uptodate

## Contrib libraries (see later)
## Docu (see later)
## Style
# brew install cppcheck uncrustify
## Memory
# brew install valgrind

# Rough check of the setup
cd $SOURCE_PATH
  REPO=$(git config --get remote.origin.url)
  if [[ "$REPO" != *OpenMS.git ]]
    then
    echo $REPO
    echo "SOURCE_PATH does not seem to be a clone of the OpenMS git repo."
    exit 1
  fi
cd ..

## Infer architecture and other infos of this machine (32/64)
ARCH_NO_BIT=$(getconf LONG_BIT)
ARCH="$ARCH_NO_BIT"bit
# Use script tools to infer system details
if [ "$(uname -s)" == "Darwin" ]; then
    OS="macOS"
    VER=$(sw_vers -productVersion)
    PACK_TYPE="dmg"
    THIRDPARTY_SUBFOLDER="MacOS"
  else 
    echo "Wrong platform. This script currently inly runs in macOS."
fi
export SYSTEM_ID=${OS}_${VER}_${ARCH}

# Install OpenMS dependencies
# QT is not in the contrib. Always download.
#tick
#brew install qt >> $LOG_PATH/packages.log 2>&1
#echo "Setting up QT4 took (s):"
#tock

# PyOpenMS:
if [ "$PYOPENMS" == "ON" ]
then
  tick
  sudo easy_install pip >> $LOG_PATH/pip_packages.log 2>&1
  # On non-clean Macs we should use virtualenv
  if (true)
  then
    # Install virtualenv
    pip install virtualenv
    virtualenv ~/pyopenms_venv
    chmod +x ~/pyopenms_venv/bin/activat*
    sourceHere ~/pyopenms_venv/bin/activate \
    pip install -U setuptools pip autowrap nose numpy wheel > $LOG_PATH/pip_packages.log 2>&1
  else
    #Just install system wide
    sudo pip install -U setuptools pip autowrap nose numpy wheel > $LOG_PATH/pip_packages.log 2>&1
  fi
  echo "Setting up pyOpenMS dependencies and pip packages took (s):"
  tock
fi

## Skip for now. All our Macs should have a running Quartz for now.
## If not: Install XQuartz and run the Xvfb like on Linux.
# Virtual Xserver for OpenMS -WITH_GUI option
#if [ "$WITH_GUI" == "ON" ] && [ "$HAS_XSERVER" == "OFF" ]
#  then
#    tick
#    ## TODO install XQuartz >> $LOG_PATH/xquartz.log 2>&1
#    Xvfb :1 -screen 0 1024x768x24 2>$LOG_PATH/XServer.log &
#
#    export DISPLAY=":1"
#
#    ## To close the Xserver before the script ends
#    function finish {
#      kill -s 15 $(cat /tmp/.X1-lock)
#    }
#    trap finish EXIT
#    echo "Setting up virtual X-Server on Display 1 took (s):"
#    tock
#fi

# For Thirdparty tests (e.g. MSGF+, LuciPhor)
# On Mac it is hard to install only JRE from command line. Take the easy way and install brew's JDK.
if ! [ -z ${SEARCH_ENGINES_DIRECTORY+x} ]
then
  tick
  #brew cask install java >> $LOG_PATH/packages.log 2>&1
  mkdir $SEARCH_ENGINES_DIRECTORY || true
  ## Caution: with svn 1.8.8 the link /branches/master/ had to be substituted with /trunk/. Error seems to be relatively unknown on the internet.
  ## Maybe /branches/master/ first occurs if there are multiple branches. I have no clue! It also seems to depend on the
  ## recent changes.
  ## Alternative: 1) Git archive (does not work with github). 2) A "local" git repo mounted as volume.
  svn export --force https://github.com/OpenMS/THIRDPARTY/trunk/All $SEARCH_ENGINES_DIRECTORY > $LOG_PATH/git.log || echo "Cloning of multiplatform Thirdparty binaries went wrong"
  svn export --force https://github.com/OpenMS/THIRDPARTY/trunk/MacOS/${ARCH_NO_BIT}bit $SEARCH_ENGINES_DIRECTORY >> $LOG_PATH/git.log || echo "Cloning of Linux Thirdparty binaries went wrong"
  #svn export --force https://github.com/OpenMS/THIRDPARTY/branches/master/All $SEARCH_ENGINES_DIRECTORY > $LOG_PATH/git.log || echo "Cloning of multiplatform Thirdparty binaries went wrong"
  #svn export --force https://github.com/OpenMS/THIRDPARTY/branches/master/Linux/${ARCH_NO_BIT}bit $SEARCH_ENGINES_DIRECTORY >> $LOG_PATH/git.log || echo "Cloning of Linux Thirdparty binaries went wrong"
  echo "Downloading JDK and Thirdparty tools took (s):"
  tock
fi

## Except for brew packages the same on macOS. Maybe check that e.g. no MacTex was installed.
if [ "${PACKAGE_TEST}" == "ON" ] || [ "${BUILD_DOCU}" == "ON" ]
then
  tick
  #brew install doxygen ghostscript graphviz >> $LOG_PATH/packages.log 2>&1
  #brew cask install basictex
  ## TODO or
  #brew cask install mactex
  echo "Setting up Docu tools incl. MacTex took (s):"
  tock
  tick
fi


## libz and libbz are preinstalled system libraries on macOS
if $DOWNLOAD_CONTRIB
  then
  tick
  if ! $USE_DISTRO_CONTRIB
  then
    echo "Downloading contrib ..."
    wget -O contrib_build.tar.gz $CONTRIB_URL > $LOG_PATH/contrib_setup.log 2>&1
    ## TAR should contain contrib-build as root folder
    tar -xzf contrib_build.tar.gz
  else
    # Wildmagic, CoinOr and the old seqan version 1.4 are not in the standard repos.
    # Always build with contrib.
    ## TODO find a way to choose subset
    echo "Please download the full contrib for now."
    # If not installed through contrib
    ## Contrib libraries
    # tap the science tap
    #brew tap homebrew/science
    #brew tap homebrew/versions
    #brew install qt glpk eigen boost xerces-c coinmp libsvm >> $LOG_PATH/packages.log 2>&1
  fi
  echo "Setting up contrib took (s):"
  tock
fi
#else
## Contrib build with our git sourceHeres: seqan wildmagic
#git clone https://github.com/OpenMS/contrib.git
#mkdir contrib-build
#cd contrib-build
#cmake -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang -DBUILD_TYPE=SEQAN ~/openms-development/contrib
#cmake -DBUILD_TYPE=WILDMAGIC .

######################################################     build script    ##################################################################################


skip_tests=false
if ! $skip_tests
then
  ## Clone CMake scripts
  git clone https://github.com/OpenMS/build-scripts $SCRIPT_GIT_ROOT || echo "Cloning of scripts went wrong"
  export SCRIPT_PATH="$SCRIPT_GIT_ROOT/nightlies/generic_scripts"
 
  cd $SCRIPT_PATH
  tick
  ${SCAN_BUILD_PREFIX} ctest --no-compress-output -S run_tests.cmake -C $build_type #> %LOG_PATH%\ctest.log
  echo "CTest script took (s):"
  tock
  #echo "Result:"
  #cat %LOG_PATH%\ctest.log

else
  ## Debug: just build, no tests, except running some binaries
  cd ${BUILD_PATH}
  
  ${SCAN_BUILD_PREFIX} cmake  \
  -DCMAKE_C_COMPILER=${CC} \
  -DCMAKE_CXX_COMPILER=${CXX} \
  -j${NUMBER_THREADS} \
  -DCMAKE_PREFIX_PATH="${CONTRIB_PATH};${QT4_PATH};${QT4_PATH}bin;/usr;/usr/local" \
  -DBOOST_USE_STATIC=OFF \
  -DSEARCH_ENGINES_DIRECTORY="${SEARCH_ENGINES_DIRECTORY}" \
  ${SOURCE_PATH}

  make
  ./bin/OpenMSInfo
  ./src/tests/class_tests/bin/TOPPView_test
fi


