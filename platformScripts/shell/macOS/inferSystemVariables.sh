sourceHere ./updatePackageManager.sh
export SUBDISTRO_NAME="macOS"
export SUBDISTRO_VERSION=$(sw_vers -productVersion)
export CONTRIB_URL="https://abibuilder.informatik.uni-tuebingen.de/archive/openms/contrib/$OPSYS/$SUBDISTRO_VERSION/$TARGET_ARCH/$COMPILER/$BUILD_TYPE/contrib_build.tar.gz"
## Just pass and execute the arguments
export function runNative {
  eval $(printf "%q " "$@")
}
