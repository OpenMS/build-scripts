sudo apt-get -y install make >> $LOG_PATH/packages.log 2>&1

# Install a more recent version of CMake to test some 3.1+ features for e.g. coverage tests
curl -sSL -O https://cmake.org/files/v3.6/cmake-3.6.2-Linux-x86_64.tar.gz
sudo tar zxf cmake-3.6.2-Linux-x86_64.tar.gz -C /opt/
export PATH="/opt/cmake-3.6.2-Linux-x86_64/bin:$PATH"
