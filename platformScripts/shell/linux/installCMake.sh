# Install a more recent version of CMake to test some 3.1+ features for e.g. coverage tests
# 3.7+ also fixes CPack issues of corrupted deb files...


curl -sSL -k -O https://github.com/Kitware/CMake/releases/download/v3.25.0/cmake-3.25.0-linux-x86_64.tar.gz

sudo tar zxf cmake-3.25.0-linux-x86_64.tar.gz -C /opt/

export PATH="/opt/cmake-3.25.0-linux-x86_64/bin:$PATH"


