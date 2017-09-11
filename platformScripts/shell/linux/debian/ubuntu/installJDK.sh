## We do not need a branch here anymore. Java8 is minimum anyway. Make sure Ubuntu14.04 has a package repo loaded that includes this package.
#sourceHere $SUBDISTRO_VERSION/installJDK.sh
sudo apt-get -y install openjdk-8-jdk >> $LOG_PATH/packages.log 2>&1
