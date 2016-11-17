sourceHere ./updatePackageManager.sh
export SUBDISTRO_NAME="macOS"
export SUBDISTRO_VERSION=$(sw_vers -productVersion)
export REMOTE_CONTRIB_FOLDER="contrib/$OPSYS/$SUBDISTRO_VERSION/$TARGET_ARCH/$COMPILER/"
export CONTRIB_URL="https://abibuilder.informatik.uni-tuebingen.de/archive/openms/$REMOTE_CONTRIB_FOLDER/contrib_build.tar.gz"
## Just pass and execute the arguments
function runNative {
  eval "$@"
}
