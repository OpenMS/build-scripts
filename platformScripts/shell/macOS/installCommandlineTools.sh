#http://apple.stackexchange.com/questions/107307/how-can-i-install-the-command-line-tools-completely-from-the-command-line
## install xcode command-line-tools (appleclang, make, svn) with something like below.

if ! [[ -z $(xcodebuild -version) ]]
then
  echo "Found xcodebuild. Checking accepted license."
  if [[ -z $(sudo xcodebuild -license accept) ]]
  then
    echo "Could not check if license is accepted. Are you sudo? Skipping check. Please make sure xcodebuild is functional."
  fi
  export SYSROOT=$(xcrun --show-sdk-path | tail -1)
  if [[ -z $(ls /usr/include) ]]
  then
    echo "xcodebuild found, but no /usr/include headers which are e.g. needed for contrib. Please install the Xcode Command Line Developer Tools with sudo xcode-select --install."
  fi
else
  echo "xcodebuild not found. Trying to install.. (mechanism only works on 10.9+). Probably it doesnt even there. Please just install XCode (AppStore) and the Command Line Developer tools (sudo xcode-select --install)."
  #sudo xcode-select --install
  #sleep 1
  #osascript <<EOD
  #  tell application "System Events"
  #    tell process "Install Command Line Developer Tools"
  #      keystroke return
  #      click button "Agree" of window "License Agreement"
  #    end tell
  #  end tell
#EOD
#  sudo xcodebuild -license accept || echo "Cannot accept XCode license. XCode install not successful? Do you have sudo permissions?"
fi

