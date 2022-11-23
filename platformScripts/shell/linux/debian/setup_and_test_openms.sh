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

# Tools for the scripts
tick
sudo apt-get -y update
sudo apt-get -y install curl git tar vim wget zip openssh-server subversion lsb-release > $LOG_PATH/packages.log 2>&1
echo "Setting up scripting utilities took (s):"
tock

# Rough check of the setup
cd $SOURCE_PATH
  REPO=$(git config --get remote.origin.url)
  if [[ "$REPO" != *OpenMS ]]
    then
    echo "SOURCE_PATH does not seem to be a clone of the OpenMS git repo."
    exit 1
  fi
cd ..

# Use script tools to infer system details
## Requires lsb_release to be installed for Linux distros
## Please configure to your needs
OS=$(lsb_release -si)
VER=$(lsb_release -sr)
## Should work on almost all distros
ARCH=$(uname -m | sed 's/x86_/x/;s/i[3-6]86/x86/')
ARCH_NO_BIT=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
export SYSTEM_ID=${OS}_${VER}_${ARCH}
export GENERATOR="Unix Makefiles"

# Install required build tools for OpenMS
tick
sudo apt-get -y install make >> $LOG_PATH/packages.log 2>&1

# Install a more recent version of CMake to test some 3.1+ features for e.g. coverage tests
curl -sSL -O https://github.com/Kitware/CMake/releases/download/v3.25.0/cmake-3.25.0-linux-x86_64.tar.gz
sudo tar zxf cmake-3.25.0-linux-x86_64.tar.gz -C /opt/
export PATH="/opt/cmake-3.25.0-linux-x86_64/bin:$PATH"

echo "Setting up OpenMS core build tools took (s):"
tock

# Install OpenMS dependencies
# QT is not in the contrib. Always download (libqtwebkit4 is extra on 16.04)
tick
sudo apt-get -y install qt4-dev-tools libqtwebkit4 >> $LOG_PATH/packages.log 2>&1
echo "Setting up QT4 took (s):"
tock

# PyOpenMS:
if [ "$PYOPENMS" == "ON" ]
then
  tick
  sudo apt-get -y install python python-dev python-pip >> $LOG_PATH/packages.log 2>&1
  # I think on a Docker image we do not need virtualenv?
  if (false)
  then
    # Install virtualenv
    pip install virtualenv
    # Setup python for pyOpenMS. You have to start virtualenv when you want to use it.
    #sudo -Hu jenkins virtualenv /home/jenkins/pyopenms_venv
    virtualenv /home/jenkins/pyopenms_venv
    chmod +x /home/jenkins/pyopenms_venv/bin/activat*
    #sudo -Hu jenkins /bin/bash -c "sourceHere /home/jenkins/pyopenms_venv/bin/activate \
    #                               && pip install -U setuptools pip autowrap nose numpy wheel"
    sourceHere /home/jenkins/pyopenms_venv/bin/activate \
    pip install -U setuptools pip autowrap nose pytest numpy wheel > $LOG_PATH/pip_packages.log 2>&1
  else
    #Just install system wide
    sudo pip install -U setuptools pip autowrap nose pytest numpy wheel > $LOG_PATH/pip_packages.log 2>&1
  fi
  echo "Setting up pyOpenMS dependencies and pip packages took (s):"
  tock
fi
# Install OpenMS dependencies that are used for testing and CI only

# Virtual Xserver for OpenMS -WITH_GUI option
if [ "$WITH_GUI" == "ON" ]
  then
    tick
    sudo apt-get -y install xvfb >> $LOG_PATH/packages.log 2>&1
  ## Careful: This assumes it runs on docker images with a Xvfb installed and that are freshly booted (i.e. no Xserver running on 1)
  Xvfb :1 -screen 0 1024x768x24 2>$LOG_PATH/XServer.log &

  export DISPLAY=":1"

  ## To close the Xserver before the script ends
  function finish {
    kill -s 15 $(cat /tmp/.X1-lock)
  }
  trap finish EXIT
    echo "Setting up virtual X-Server on Display 1 took (s):"
    tock
fi

# For Thirdparty tests (e.g. MSGF+, LuciPhor)
if ! [ -z ${SEARCH_ENGINES_DIRECTORY+x} ]
then
  tick
  sudo apt-get -y install default-jre-headless >> $LOG_PATH/packages.log 2>&1
  mkdir $SEARCH_ENGINES_DIRECTORY || true
  ## Caution: with svn 1.8.8 the link /branches/master/ had to be substituted with /trunk/. Error seems to be relatively unknown on the internet.
  ## Maybe /branches/master/ first occurs if there are multiple branches. I have no clue! It also seems to depend on the
  ## recent changes.
  ## Alternative: 1) Git archive (does not work with github). 2) A "local" git repo mounted as volume.
  svn export --force https://github.com/OpenMS/THIRDPARTY/trunk/All $SEARCH_ENGINES_DIRECTORY > $LOG_PATH/thirdparty_git.log || echo "Cloning of multiplatform Thirdparty binaries went wrong"
  svn export --force https://github.com/OpenMS/THIRDPARTY/trunk/Linux/${ARCH_NO_BIT}bit $SEARCH_ENGINES_DIRECTORY >> $LOG_PATH/thirdparty_git.log || echo "Cloning of Linux Thirdparty binaries went wrong"
  #svn export --force https://github.com/OpenMS/THIRDPARTY/branches/master/All $SEARCH_ENGINES_DIRECTORY > $LOG_PATH/git.log || echo "Cloning of multiplatform Thirdparty binaries went wrong"
  #svn export --force https://github.com/OpenMS/THIRDPARTY/branches/master/Linux/${ARCH_NO_BIT}bit $SEARCH_ENGINES_DIRECTORY >> $LOG_PATH/git.log || echo "Cloning of Linux Thirdparty binaries went wrong"
  echo "Downloading JRE and Thirdparty tools took (s):"
  tock
fi

# We need jar to zip binaries as jar for KNIME (otherwise jre-headless would be fine)
if [ "${ENABLE_PREPARE_KNIME_PACKAGE}" == "ON" ]
then
  tick
  sudo apt-get -y install default-jdk >> $LOG_PATH/packages.log 2>&1
  echo "Downloading JDK for KNIME packaging took (s):"
  tock
fi

if [ "${PACKAGE_TEST}" == "ON" ] || [ "${BUILD_DOCU}" == "ON" ]
then
  sudo apt-get -y install doxygen graphviz ghostscript >> $LOG_PATH/packages.log 2>&1
  # For full docu we need latex and pdflatex with some packages
  TL=install-tl
  mkdir -p $TL
  # texlive net batch installation
  wget -nv -O $TL.tar.gz http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
  tar -xzf $TL.tar.gz -C $TL --strip-components=1
  cd $TL
    wget ${ARCHIVE_URL_PREFIX}/contrib/os_support/openmsdocu_texlive.profile
    sudo ./install-tl --persistent-downloads --profile openmsdocu_texlive.profile > $LOG_PATH/texlive.log 2>&1
  cd ..
  sudo ln -s /usr/local/texlive/bin/x86_64-linux /opt/texbin
  export PATH=$PATH:/usr/local/texlive/bin/x86_64-linux
  # cleanup
  rm $TL.tar.gz && rm -r $TL
  # Minimal nr of additional packages for docu (might be preinstalled depending on the install config of TL)
  # Does not include fonts. Always install fonts-recommended and fonts-extra for now.
  # sudo uses different path. Therefore the which.
  sudo $(which tlmgr) install oberdiek amsmath babel carlisle ec geometry lm marvosym graphics-def latex latex-bin fancyhdr graphics float \
        colortbl xcolor xtab newtx fontaxes xkeyval etoolbox kastrup tex-gyre tools hyperref listings url parskip tocloft > $LOG_PATH/texpackages.log 2>&1
        
  echo "Setting up Docu tools incl. Latex took (s):"
  tock
  tick
fi

if $DOWNLOAD_CONTRIB
  then
  tick
  if ! $USE_DISTRO_CONTRIB
  then
    echo "Downloading full contrib build from archive ..."
    wget -O contrib_build.tar.gz $CONTRIB_URL > $LOG_PATH/contrib_setup.log 2>&1
    ## TAR should contain contrib-build as root folder
    tar -xzf contrib_build.tar.gz
  else
    # Wildmagic, CoinOr and the old seqan version 1.4 are not in the standard repos.
    # Always build with contrib.
    ## TODO find a way to choose subset
    
    # If not installed through contrib
    # libzip might actually not be necessary but it is very small
    sudo apt-get -y install libboost-regex-dev libboost-iostreams-dev libboost-date-time-dev libboost-math-dev \
                            libsvm-dev \
                            libglpk-dev \
                            libzip-dev \
                            zlib1g-dev \
                            libxerces-c-dev \ 
                            libbz2-dev >> $LOG_PATH/packages.log 2>&1
  fi
  echo "Setting up contrib took (s):"
  tock
fi

######################################################     build script    ##################################################################################


# TODO add support for different compilers (potentially as another axis)
# Make axis: gcc, clang (possibly with versions)
# Then try to find a matching binary in usr/bin and usr/local/Cellar/bin (e.g. for brew)
#ls -la /usr/bin/g*


skip_tests=false
if ! $skip_tests
then
  ## Clone CMake scripts
  git clone https://github.com/OpenMS/build-scripts $SCRIPT_GIT_ROOT || echo "Cloning of scripts went wrong"
  export SCRIPT_PATH="$SCRIPT_GIT_ROOT/nightlies/generic_scripts"
 
  cd $SCRIPT_PATH
  tick
  ctest --no-compress-output -S run_tests.cmake -C $build_type #> %LOG_PATH%\ctest.log
  echo "CTest script took (s):"
  tock
  #echo "Result:"
  #cat %LOG_PATH%\ctest.log

else
  ## Debug: just build, no tests, except running some binaries
  cd ${BUILD_PATH}
  cmake -j4 -DCMAKE_PREFIX_PATH="${CONTRIB_PATH};/usr/bin;/usr;/usr/local" -DBOOST_USE_STATIC=OFF -DSEARCH_ENGINES_DIRECTORY="$SEARCH_ENGINES_DIRECTORY" ${SOURCE_PATH}
  make
  ./bin/OpenMSInfo
  ./src/tests/class_tests/bin/TOPPView_test
fi

