#python2.7 is standard on Mac but uses openssl which cant connect to pip repos
echo "Using first python in path. Use OPENMS_PYTHON to specify a specific one."
echo "$(which python)"
if ! [ -x "$(command -v pip)" ]
  then
  echo "Installing pip..."
  curl -O https://bootstrap.pypa.io/get-pip.py >> $LOG_PATH/packages.log
  python get-pip.py --user >> $LOG_PATH/packages.log
else
  echo "pip already installed. Skip."
fi
