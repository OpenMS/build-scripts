sourceHere $DISTRO/updatePackageManager.sh
sourceHere $DISTRO/installLSBRelease.sh
export SUBDISTRO_NAME=$(lsb_release -si)
export SUBDISTRO_VERSION=$(lsb_release -sr)
## we do not crosscompile on linux
export OPENMS_TARGET_ARCH=${ARCH}
## Maybe we could reduce the amount of libaries built (depends on archictecture, compiler version and stdlib).
## But we would need to test because the stdlib might be different and different distros might use patches for the compilers so that they do not have the same ABI?
export REMOTE_CONTRIB_FOLDER="contrib/$OPSYS/$DISTRO/$SUBDISTRO/$SUBDISTRO_VERSION/$OPENMS_TARGET_ARCH/$COMPILER"
export CONTRIB_URL="https://abibuilder.informatik.uni-tuebingen.de/archive/openms/$REMOTE_CONTRIB_FOLDER/contrib_build.tar.gz"

## Just pass and execute the arguments
function runNative {
  echo "Running $@"
  "$@"
}
