#python2.7 is std on Mac
if ! [ -x "$(command -v pip)" ]
  then
  curl -O https://bootstrap.pypa.io/get-pip.py >> $LOG_PATH/packages.log
  python get-pip.py --user >> $LOG_PATH/packages.log
fi
