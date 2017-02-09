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
tick "Installing QT"
sourceHere $OPSYS/installQT.sh
tock

## Skip if you already have it installed.
if $DOWNLOAD_CONTRIB
  then
  tick "Installing other contrib libraries"
  if ! $USE_DISTRO_CONTRIB
  then
    echo "Downloading full contrib build from archive $CONTRIB_URL..."
    wget -O $WORKSPACE/contrib_build.tar.gz $CONTRIB_URL > $LOG_PATH/contrib_setup.log 2>&1
    # Archive should contain no root folder, only bin, lib, include etc. (see the archiving step of the openms_contrib_all job)
    tar -xvzf $WORKSPACE/contrib_build.tar.gz --directory $CONTRIB_PATH >> $LOG_PATH/contrib_setup.log 2>&1
  else
    # Install as much as possible from the package managers
    # Build or download prebuild for the rest
    sourceHere $OPSYS/installDistroContrib.sh
  fi
  tock
  ls -la $CONTRIB_PATH || ( echo "Error: Could not find CONTRIB_PATH after download and extraction of contrib. Check logs." && exit 1)
fi

# PyOpenMS:
if [ "$PYOPENMS" == "ON" ]
then
  tick "Installing Python and PIP"
  sourceHere $OPSYS/installPythonAndPip.sh
  tock
  # I think on a Docker image we do not need virtualenv?
  tick "Installing Python packages"
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
    source /home/jenkins/pyopenms_venv/bin/activate \
    pip install -U setuptools pip autowrap nose numpy wheel > $LOG_PATH/pip_packages.log 2>&1
  else
    #Just install system wide
    sudo pip install -U setuptools pip autowrap nose numpy wheel > $LOG_PATH/pip_packages.log 2>&1
  fi
  tock
fi

# For Thirdparty tests (e.g. MSGF+, LuciPhor)
if ! [ -z ${SEARCH_ENGINES_DIRECTORY+x} ]
then
  tick "Installing JRE and Thirdparty binaries"
  sourceHere $OPSYS/installJRE.sh
  mkdir $SEARCH_ENGINES_DIRECTORY || true
  ## Caution: with svn 1.8.8 the link /branches/master/ had to be substituted with /trunk/. Error seems to be relatively unknown on the internet.
  ## Maybe /branches/master/ first occurs if there are multiple branches. I have no clue! It also seems to depend on the
  ## recent changes.
  ## Alternative: 1) Git archive (does not work with github). 2) A "local" git repo mounted as volume.
  svn export --non-interactive --trust-server-cert  --force https://github.com/OpenMS/THIRDPARTY/trunk/All $SEARCH_ENGINES_DIRECTORY > $LOG_PATH/thirdparty_git.log || echo "Cloning of multiplatform Thirdparty binaries went wrong"
  svn export --non-interactive --trust-server-cert --force https://github.com/OpenMS/THIRDPARTY/trunk/${OPSYS^}/${ARCH_NO_BIT}bit $SEARCH_ENGINES_DIRECTORY >> $LOG_PATH/thirdparty_git.log || echo "Cloning of Linux Thirdparty binaries went wrong"
  #svn export --force https://github.com/OpenMS/THIRDPARTY/branches/master/All $SEARCH_ENGINES_DIRECTORY > $LOG_PATH/git.log || echo "Cloning of multiplatform Thirdparty binaries went wrong"
  #svn export --force https://github.com/OpenMS/THIRDPARTY/branches/master/Linux/${ARCH_NO_BIT}bit $SEARCH_ENGINES_DIRECTORY >> $LOG_PATH/git.log || echo "Cloning of Linux Thirdparty binaries went wrong"
  tock
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
  sourceHere $OPSYS/installLaTeX.sh
  tock
fi
