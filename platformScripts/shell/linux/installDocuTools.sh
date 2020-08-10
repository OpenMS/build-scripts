## Currently we use the binary installer for doxygen to get at least 1.8.16 on all Linuxes
DOXYGEN_VERSION=1.8.19
curl -O http://doxygen.nl/files/doxygen-${DOXYGEN_VERSION}.linux.bin.tar.gz
sudo tar zxf doxygen-${DOXYGEN_VERSION}.linux.bin.tar.gz -C /opt/
ls -la /opt/doxygen-${DOXYGEN_VERSION}/

sourceHere $DISTRO/installDocuTools.sh
export PATH="/opt/doxygen-${DOXYGEN_VERSION}/bin:$PATH"
