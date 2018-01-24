## We do not need a branch here anymore. Java8 is minimum anyway. Make sure Ubuntu14.04 has a package repo loaded that includes this package.
## Ubuntu 14.04 (already on docker image): sudo add-apt-repository ppa:openjdk-r/ppa
## Ubuntu 14.04 (already on docker image): sudo apt-get update
sudo apt-get -y install openjdk-8-jdk >> $LOG_PATH/packages.log 2>&1
