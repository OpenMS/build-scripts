sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF >> $LOG_PATH/packages.log 2>&1
sudo apt -y install apt-transport-https ca-certificates >> $LOG_PATH/packages.log 2>&1
echo "deb https://download.mono-project.com/repo/ubuntu stable-wheezy main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list >> $LOG_PATH/packages.log 2>&1
sudo apt -y update >> $LOG_PATH/packages.log 2>&1
sudo apt -y install mono-complete >> $LOG_PATH/packages.log 2>&1
