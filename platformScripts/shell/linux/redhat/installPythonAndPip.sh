sudo yum -y install epel-release >> $LOG_PATH/packages.log 2>&1 
sudo yum -y update >> $LOG_PATH/packages.log 2>&1
sudo yum -y install python-devel python-pip python-virtualenv >> $LOG_PATH/packages.log 2>&1
