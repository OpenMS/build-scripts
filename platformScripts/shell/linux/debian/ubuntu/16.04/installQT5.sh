sudo apt-get -y install software-properties-common
sudo apt-add-repository -y ppa:beineri/opt-qt591-xenial >> $LOG_PATH/packages.log 2>&1
sudo apt-get -y update >> $LOG_PATH/packages.log 2>&1
sudo apt-get -y install qt59base qt59svg >> $LOG_PATH/packages.log 2>&1
export QT_ROOT=/opt/qt59
