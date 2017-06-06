#python2.7 is std on Mac
#append user installation to path (did not seem to work via Slave configuration)
PATH=$PATH:~/Library/Python/2.7/bin
echo "Using standard Python 2.7 preinstalled on Mac"
if ! [ -x "$(command -v pip)" ]
  then
  echo "Installing pip..."
  curl -O https://bootstrap.pypa.io/get-pip.py >> $LOG_PATH/packages.log
  python get-pip.py --user >> $LOG_PATH/packages.log
else
  echo "pip already installed. Skip."
fi
