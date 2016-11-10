#TODO We should not use development versions of Ubuntu. 16.04.2 has a development version of Java 9 already. So default-jdk will not work with CMake.
sudo apt-get install openjdk-8-jdk >> $LOG_PATH/packages.log 2>&1
