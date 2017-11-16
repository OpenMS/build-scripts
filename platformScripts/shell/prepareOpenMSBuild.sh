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
    [ "$(ls -A $CONTRIB_PATH)" ] || git -C "$SOURCE_PATH" submodule update --init contrib || ( echo "Error: Given CONTRIB_PATH is empty and no git submodule." && exit 1) 
    ## runNative is set in the inferSystemVariables.sh specifically for each platform
    runNative cmake -G "\"$GENERATOR\"" -DBUILD_TYPE=ALL ${ADDITIONAL_CMAKE_ARGUMENTS-} "\"$CONTRIB_PATH\""
  else
      # Install as much as possible from the package managers
    # Build or download prebuild for the rest
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
  virtualenv ./pyopenms_venv
  chmod +x ./pyopenms_venv/bin/activat*
  #sudo -Hu jenkins /bin/bash -c "sourceHere /home/jenkins/pyopenms_venv/bin/activate \
  #                               && pip install -U setuptools pip autowrap nose numpy wheel"
  source ./pyopenms_venv/bin/activate
  # We are in a virtualenv. We can install it without --user
  pip install -U setuptools pip autowrap nose Cython numpy wheel > $LOG_PATH/pip_packages.log 2>&1
  if [ "$RUN_PYTHON_CHECKER" == "ON" ]
  then
    pip install -U breathe pyyaml >> $LOG_PATH/pip_packages.log 2>&1
    sourceHere $OPSYS/installDocuTools.sh
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
  ## First guess was: /branches/master/ first occurs if there are multiple branches. Probably not. I have no clue! It also seems to depend on the
  ## recent changes.
  ## Alternatives: 1) Git archive (does not work with github). 2) A "local" git repo mounted as volume.
  ## For now, check both
  svn export --non-interactive --trust-server-cert --force https://github.com/OpenMS/THIRDPARTY/trunk/All $SEARCH_ENGINES_DIRECTORY > $LOG_PATH/thirdparty_git.log || \
  svn export --non-interactive --trust-server-cert --force https://github.com/OpenMS/THIRDPARTY/branches/master/All $SEARCH_ENGINES_DIRECTORY > $LOG_PATH/thirdparty_git.log || \
  echo "Cloning of multiplatform Thirdparty binaries went wrong"
  
  opsysfirst=`echo $OPSYS|cut -c1|tr [a-z] [A-Z]`
  opsyssecond=`echo $OPSYS|cut -c2-`
  # ${OPSYS^} to make first letter uppercase only works in bash4+
  
  svn export --non-interactive --trust-server-cert --force https://github.com/OpenMS/THIRDPARTY/trunk/${opsysfirst}${opsyssecond}/${ARCH_NO_BIT}bit $SEARCH_ENGINES_DIRECTORY >> $LOG_PATH/thirdparty_git.log || \
  svn export --non-interactive --trust-server-cert --force https://github.com/OpenMS/THIRDPARTY/branches/master/${opsysfirst}${opsyssecond}/${ARCH_NO_BIT}bit $SEARCH_ENGINES_DIRECTORY >> $LOG_PATH/thirdparty_git.log || \
  echo "Cloning of platform-specific Thirdparty binaries went wrong"

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
  sourceHere $OPSYS/installLatex.sh
  tock
fi

if [ "${PACKAGE_TEST}" == "ON" ]
then
  tick "Setting up packaging tools"
  sourceHere $OPSYS/installPackagingTools.sh
  tock
fi
