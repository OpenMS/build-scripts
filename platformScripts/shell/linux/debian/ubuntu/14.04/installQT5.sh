sudo apt-get -y install software-properties-common libgl1-mesa-dev
sudo apt-add-repository -y ppa:beineri/opt-qt591-trusty >> $LOG_PATH/packages.log 2>&1
sudo apt-get -y update >> $LOG_PATH/packages.log 2>&1
sudo apt-get -y install qt59base qt59svg >> $LOG_PATH/packages.log 2>&1
source /opt/qt59/bin/qt*-env.sh
export QT_ROOT=/opt/qt59
