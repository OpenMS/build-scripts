## Currently we use the binary installer for doxygen to get at least 1.8.16 on all Linuxes
curl -O http://doxygen.nl/files/doxygen-1.8.16.linux.bin.tar.gz
sudo tar zxf doxygen-1.8.16.linux.bin.tar.gz -C /opt/
export PATH="/opt/doxygen-1.8.16/bin:$PATH"

sourceHere $DISTRO/installDocuTools.sh
