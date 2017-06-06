#python2.7 is std on Mac
echo "Using standard Python 2.7 preinstalled on Mac"
if ! [ -x "$(command -v pip)" ]
  then
  echo "Installing pip..."
  curl -O https://bootstrap.pypa.io/get-pip.py >> $LOG_PATH/packages.log
  python get-pip.py --user >> $LOG_PATH/packages.log
else
  echo "pip already installed. Skip."
fi
