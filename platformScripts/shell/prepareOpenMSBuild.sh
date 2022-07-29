tick "Updating package manager"
sourceHere $OPSYS/updatePackageManager.sh
tock

tick "Installing scripting tools"
sourceHere $OPSYS/installScriptingTools.sh
tock

# Rough check of the setup, needs Git
checkGitRepo $SOURCE_PATH

tick "Installing required build tools for OpenMS"
sourceHere $OPSYS/installBuildTools.sh
tock

# Virtual Xserver for OpenMS -WITH_GUI option
if [ "$WITH_GUI" == "ON" ]
  then
    tick "Checking for/installing running Window Server"
    sourceHere $OPSYS/startWindowServer.sh
    tock
fi

# Install OpenMS dependencies
# QT is not in the contrib. Always download if possible.

## Hack until QT5 is stabilized or we include the build-scripts into the OpenMS repo
if [ "$(grep 'Qt 4' $SOURCE_PATH/License.txt | wc -l )" -ge 1 ]
then
  export QT_VERSION=4
else
  export QT_VERSION=5
fi

tick "Installing QT"
sourceHere $OPSYS/installQT$QT_VERSION.sh
tock


tick "Installing other contrib libraries"
if $DOWNLOAD_CONTRIB
  then
    echo "Downloading full contrib build from archive $CONTRIB_URL..."
    curl -O $CONTRIB_URL > $LOG_PATH/contrib_setup.log 2>&1
    # Archive should contain no root folder, only bin, lib, include etc. (see the archiving step of the openms_contrib_all job)
    # force-local to allow usage of mixed POSIX/Win paths (e.g. starting with C:), otherwise interpreted as remote location
    tar ${force_local_flag:-} -xvzf contrib_build.tar.gz --directory $CONTRIB_PATH >> $LOG_PATH/contrib_setup.log 2>&1
    sourceHere $OPSYS/fixContribInstallNames.sh
    echo "Checking extraction results of contrib..."
    ls -la $CONTRIB_PATH || ( echo "Error: Could not find CONTRIB_PATH after download and extraction of contrib. Check logs." && exit 1)
else
  if ! $USE_DISTRO_CONTRIB
  then ## Build contrib
    if [ -z ${CONTRIB_SOURCE_PATH+x} ]
    then
      echo "CONTRIB_SOURCE_PATH not set. Using git submodule of OpenMS source."
      git -C "$SOURCE_PATH" submodule update --init contrib || ( echo "Error: No git submodule is present in the OpenMS sources of SOURCE_PATH." && exit 1) 
      export CONTRIB_SOURCE_PATH=$SOURCE_PATH/contrib
    fi
    sourceHere $OPSYS/installContribBuildTools.sh
    ## runNative is set in the inferSystemVariables.sh specifically for each platform
    pushd $CONTRIB_PATH
      runNative cmake -G "\"$GENERATOR\"" -DBUILD_TYPE=ALL ${ADDITIONAL_CMAKE_ARGUMENTS-} "\"$CONTRIB_SOURCE_PATH\""
    popd
  else
    # Install as much as possible from the package managers
    # Build or download prebuild for the rest (TODO not finished yet)
    sourceHere $OPSYS/installDistroContrib.sh
  fi 
fi

# PyOpenMS:
if [ "$PYOPENMS" == "ON" ]
then
  tick "Installing Python and PIP"
  sourceHere $OPSYS/installPythonAndPip.sh
  tock
  # I think on a Docker image we do not need virtualenv?
  tick "Installing Python packages in a virtualenv"
  # Install virtualenv (if not installed via package managers which is suggested on Linux)
  command -v virtualenv >/dev/null 2>&1 || pip install --user -U virtualenv
  # Setup python for pyOpenMS. You have to start virtualenv when you want to use it.
  #sudo -Hu jenkins virtualenv /home/jenkins/pyopenms_venv
  if [ -z ${OPENMS_PYTHON+x} ]
  then
    echo "Variable OPENMS_PYTHON not found, using the python that is associated with / shipped virtualenv for pyOpenMS."
    VIRTUALENVPARAM=""
  else
    VIRTUALENVPARAM="-p ${OPENMS_PYTHON}"
  fi
  virtualenv $VIRTUALENVPARAM $WORKSPACE/pyopenms_venv
  # Activate is under bin on Unix and Script on Win. It sets the python, pip etc. to the one in the venv.
  chmod +x $(/usr/bin/find $WORKSPACE/pyopenms_venv -name "activate")
  source $(/usr/bin/find $WORKSPACE/pyopenms_venv -name "activate")
  # Basically a check if on Windows.
  ls $WORKSPACE/pyopenms_venv/bin/ > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    export PYTHON_EXECUTABLE=$WORKSPACE/pyopenms_venv/bin/python
  else
    export PYTHON_EXECUTABLE=$WORKSPACE/pyopenms_venv/Scripts/python.exe
  fi
  
  # We are in a virtualenv. We can install it without --user
  #pip install -U setuptools pip==9.0.3 autowrap nose Cython numpy pandas wheel > $LOG_PATH/pip_packages.log 2>&1
  pip install -U setuptools pip autowrap nose pytest Cython numpy pandas wheel > $LOG_PATH/pip_packages.log 2>&1
  
  if [ "$RUN_PYTHON_CHECKER" == "ON" ]
  then
    if [ -z ${HELPER_PYTHON+x} ]
    then
      echo "Variable HELPER_PYTHON not found, using the python that is associated with / shipped virtualenv for helper scripts. Make sure that it is Python2"
      VIRTUALENVPARAM_HELPER=""
    else
      VIRTUALENVPARAM_HELPER="-p ${HELPER_PYTHON}"
    fi
    # If it's the same as for pyopenms, use the old venv
    if [ "$VIRTUALENVPARAM_HELPER" == "$VIRTUALENVPARAM" ]
    then
      export PYTHON_EXECUTABLE_HELPER=$PYTHON_EXECUTABLE
      PIP_HELPER=pip  
    else
      # Create a new one
      virtualenv $VIRTUALENVPARAM_HELPER $WORKSPACE/helper_python_venv
      ls $WORKSPACE/pyopenms_venv/bin/ > /dev/null 2>&1
      if [ $? -eq 0 ]; then
        export PYTHON_EXECUTABLE_HELPER=$WORKSPACE/helper_python_venv/bin/python
        PIP_HELPER=$WORKSPACE/helper_python_venv/bin/pip
      else
        export PYTHON_EXECUTABLE_HELPER=$WORKSPACE/helper_python_venv/Scripts/python.exe
        PIP_HELPER=$WORKSPACE/helper_python_venv/Scripts/pip.exe
      fi
    fi
    $PIP_HELPER install -U pip breathe pyyaml autowrap Cython >> $LOG_PATH/pip_packages.log 2>&1
    sourceHere $OPSYS/installDocuTools.sh
  fi
  tock
fi

# For Thirdparty tests (e.g. MSGF+, LuciPhor)
if ! [ -z ${SEARCH_ENGINES_DIRECTORY+x} ]
then
  tick "Installing JRE for Thirdparty tests..."
    sourceHere $OPSYS/installJRE.sh
  tock
  
  tick "Installing mono for RawfileParser Thirdparty tests..."
    sourceHere $OPSYS/installMono.sh
  tock
  
  mkdir -p $SEARCH_ENGINES_DIRECTORY
  ## To get the naming of the thirdparty subdirs
  opsysfirst=`echo $OPSYS|cut -c1|tr [a-z] [A-Z]`
  opsyssecond=`echo $OPSYS|cut -c2-`
  # ${OPSYS^} to make first letter uppercase only works in bash4+
    
  if ! $USE_THIRDPARTY_SUBMODULE
  then
    tick "Downloading public Thirdparties via git svn"
    ## Caution: with svn 1.8.8 the link /branches/master/ had to be substituted with /trunk/. Error seems to be relatively unknown on the internet.
    ## First guess was: /branches/master/ first occurs if there are multiple branches. Probably not. I have no clue! It also seems to depend on the
    ## recent changes.
    ## Alternatives: 1) Git archive (does not work with github). 2) A "local" git repo mounted as volume.
    ## For now, check both
    svn export --non-interactive --trust-server-cert --force https://github.com/OpenMS/THIRDPARTY/trunk/All $SEARCH_ENGINES_DIRECTORY > $LOG_PATH/thirdparty_git.log || \
    svn export --non-interactive --trust-server-cert --force https://github.com/OpenMS/THIRDPARTY/branches/master/All $SEARCH_ENGINES_DIRECTORY > $LOG_PATH/thirdparty_git.log || \
    echo "Cloning of multiplatform Thirdparty binaries went wrong"

    svn export --non-interactive --trust-server-cert --force https://github.com/OpenMS/THIRDPARTY/trunk/${opsysfirst}${opsyssecond}/${ARCH_NO_BIT}bit $SEARCH_ENGINES_DIRECTORY >> $LOG_PATH/thirdparty_git.log || \
    svn export --non-interactive --trust-server-cert --force https://github.com/OpenMS/THIRDPARTY/branches/master/${opsysfirst}${opsyssecond}/${ARCH_NO_BIT}bit $SEARCH_ENGINES_DIRECTORY >> $LOG_PATH/thirdparty_git.log || \
    echo "Cloning of platform-specific Thirdparty binaries went wrong"

    tock
  else
    tick "Cloning and flattening Thirdparty submodule"
    
    git -C "$SOURCE_PATH" submodule update --init THIRDPARTY
    cp -r $SOURCE_PATH/THIRDPARTY/All/* $SEARCH_ENGINES_DIRECTORY
    cp -r $SOURCE_PATH/THIRDPARTY/${opsysfirst}${opsyssecond}/${ARCH_NO_BIT}bit/* $SEARCH_ENGINES_DIRECTORY

    tock
  fi
  if ! [ -z ${PRIVATE_THIRDPARTY_DIRECTORY_CLONE+x} ]
  then
    mkdir -p ${PRIVATE_THIRDPARTY_DIRECTORY}
    cp -r ${PRIVATE_THIRDPARTY_DIRECTORY_CLONE}/All/* ${PRIVATE_THIRDPARTY_DIRECTORY}
    cp -r ${PRIVATE_THIRDPARTY_DIRECTORY_CLONE}/${opsysfirst}${opsyssecond}/${ARCH_NO_BIT}bit/* ${PRIVATE_THIRDPARTY_DIRECTORY} || true
    ## arch. dep. tps not yet available
  fi
fi

## Potential Sirius login
if ! [ -z ${SIRIUSPW+x} ]
then
  if [ -d ${SEARCH_ENGINES_DIRECTORY}/Sirius ]
  then
    VERSIONLINE=$(./${SEARCH_ENGINES_DIRECTORY}/Sirius/sirius --version 2>&1 | grep "You run SIRIUS")
    ## Starting from Sirius 5 you have to login for WebAPI functionality
    if [[ $VERSIONLINE =~ ".* [5-9]\.[0-9]+\.[0-9]+$" ]]
    then
      echo "Logging in Sirius..."
      ./${SEARCH_ENGINES_DIRECTORY}/Sirius/sirius login --email="$SIRIUSUSER" --password="$SIRIUSPW" || echo "Login failed."
    fi
  else
    echo "WARNING: Sirius not found. Check THIRDPARTY structure."
  fi
else
  echo "WARNING: No password for SIRIUS found. Skipping login. This might fail tests with Sirius online functionality."
fi

# We need jar to zip binaries as jar for KNIME (otherwise jre-headless would be fine)
if [ "${ENABLE_PREPARE_KNIME_PACKAGE}" == "ON" ]
then
  tick "Installing JDK for KNIME packaging"
  sourceHere $OPSYS/installJDK.sh 
  tock
fi

if [ "${PACKAGE_TEST}" == "ON" ] || [ "${BUILD_DOCU}" == "ON" ]
then
  tick "Setting up Docu tools"
  sourceHere $OPSYS/installDocuTools.sh
  tock
  # For full docu we need latex (formulas in html) and
  # pdflatex (tutorials) with some packages
  tick "Setting up LaTeX"
  sourceHere $OPSYS/installLatex.sh
  tock
fi

if [ "${PACKAGE_TEST}" == "ON" ]
then
  tick "Setting up packaging tools"
  sourceHere $OPSYS/installPackagingTools.sh
  tock
fi
