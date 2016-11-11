#source $SUBDISTRO/installLSBRelease.sh
sudo $PACKAGEMAN -y update
sudo $PACKAGEMAN -y install lsb_release
SUBDISTRO_NAME=$(lsb_release -si)
SUBDISTRO_VERSION=$(lsb_release -sr)
