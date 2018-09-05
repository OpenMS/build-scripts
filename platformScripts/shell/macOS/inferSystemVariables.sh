export SUBDISTRO_NAME="macOS"
export SUBDISTRO_VERSION=$(sw_vers -productVersion)
export OPENMS_TARGET_ARCH=${ARCH}
export REMOTE_CONTRIB_FOLDER="contrib/$OPSYS/$SUBDISTRO_VERSION/$OPENMS_TARGET_ARCH/$COMPILER/"
export CONTRIB_URL="https://abibuilder.informatik.uni-tuebingen.de/archive/openms/$REMOTE_CONTRIB_FOLDER/contrib_build.tar.gz"
## Special for macOS to allow multiple brew installations
if [ -z "${OPENMS_BREW_FOLDER+x}" ]
then
  echo "OPENMS_BREW_FOLDER was not set. Using standard brew installation under /usr/local"
  export OPENMS_BREW_FOLDER="/usr/local"
fi
export PATH="${PATH}:${OPENMS_BREW_FOLDER}/bin"
export OPENMS_BREW="${OPENMS_BREW_FOLDER}/bin/brew"

if [ -z "${loginpw+x}" ]
then
else
  echo "loginpw was set. Trying to unlock login keychain to access signing identities."
  security unlock-keychain -p $loginpw login.keychain
fi

## Just pass and execute the arguments
function runNative {
  echo "Running $*"
  bash -c "$*"
}

sourceHere ./updatePackageManager.sh
