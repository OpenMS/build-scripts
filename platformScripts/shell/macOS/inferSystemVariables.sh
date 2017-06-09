sourceHere ./updatePackageManager.sh
export SUBDISTRO_NAME="macOS"
export SUBDISTRO_VERSION=$(sw_vers -productVersion)
export OPENMS_TARGET_ARCH=${ARCH}
export REMOTE_CONTRIB_FOLDER="contrib/$OPSYS/$SUBDISTRO_VERSION/$OPENMS_TARGET_ARCH/$COMPILER/"
export CONTRIB_URL="https://abibuilder.informatik.uni-tuebingen.de/archive/openms/$REMOTE_CONTRIB_FOLDER/contrib_build.tar.gz"
## Special for macOS to allow multiple brew installations
export PATH=${PATH};${OPENMS_BREW_FOLDER}/bin
## Just pass and execute the arguments
function runNative {
  echo "Running $@"
  "$@"
}
