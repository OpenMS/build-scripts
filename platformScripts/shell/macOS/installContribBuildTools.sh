sourceHere installCommandlineTools.sh
## tar and patch are standard on macOS, libtool via brew installs glibtoolize with a g prepended (CMake will take care of this).
brew install cmake autoconf automake libtool >> $LOG_PATH/packages.log 2>&1
