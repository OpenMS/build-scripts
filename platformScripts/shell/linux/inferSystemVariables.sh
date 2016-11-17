sourceHere $DISTRO/updatePackageManager.sh
sourceHere $DISTRO/installLSBRelease.sh
export SUBDISTRO_NAME=$(lsb_release -si)
export SUBDISTRO_VERSION=$(lsb_release -sr)
export TARGET_ARCH=${ARCH}
## Maybe we could reduce the amount of libaries built (depends on archictecture, compiler version and stdlib).
## But we would need to test because the stdlib might be different and different distros might use patches for the compilers so that they do not have the same ABI?
export CONTRIB_URL="https://abibuilder.informatik.uni-tuebingen.de/archive/openms/contrib/$OPSYS/$DISTRO/$SUBDISTRO_NAME/$SUBDISTRO_VERSION/$TARGET_ARCH/$COMPILER/$BUILD_TYPE/contrib_build.tar.gz"
