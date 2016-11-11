sourceHere $DISTRO/updatePackageManager.sh
sourceHere $DISTRO/installLSBRelease.sh
SUBDISTRO_NAME=$(lsb_release -si)
SUBDISTRO_VERSION=$(lsb_release -sr)
