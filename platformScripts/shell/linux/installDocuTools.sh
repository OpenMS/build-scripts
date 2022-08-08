## Currently we use the binary installer for doxygen to get at least 1.8.16 on all Linuxes
## We cannot go higher currently, since 1.8.16 is the last one that works on 16.04. Newer ones also do not build with g++<5 
## which means we would need to install two g++s when building with our last supported compiler.

DOXYGEN_VERSION=1.9.4
curl -L -o doxygen-${DOXYGEN_VERSION}.linux.bin.tar.gz https://sourceforge.net/projects/doxygen/files/rel-${DOXYGEN_VERSION}/doxygen-${DOXYGEN_VERSION}.linux.bin.tar.gz/download > $LOG_PATH/doxygen_install.log 2>&1
sudo tar zxf doxygen-${DOXYGEN_VERSION}.linux.bin.tar.gz -C /opt/ >> $LOG_PATH/doxygen_install.log 2>&1
ls -la /opt/doxygen-${DOXYGEN_VERSION}/ >> $LOG_PATH/doxygen_install.log 2>&1

sourceHere $DISTRO/installDocuTools.sh
export PATH="/opt/doxygen-${DOXYGEN_VERSION}/bin:$PATH"
