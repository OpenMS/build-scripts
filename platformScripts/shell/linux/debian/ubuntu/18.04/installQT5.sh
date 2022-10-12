# install sqlite, too, to make it publicly findable. Otherwise Qt just uses a hidden dynamic sqlite lib
# and we dont find it. We cannot use the one from contrib, otherwise the programs crash. Due to symbol/implementation mismatches
sudo apt-get -y install qtbase5-dev libqt5svg5-dev libsqlite3-dev libqt5sql5-sqlite >> $LOG_PATH/packages.log 2>&1
