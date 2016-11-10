#http://apple.stackexchange.com/questions/107307/how-can-i-install-the-command-line-tools-completely-from-the-command-line
## install xcode command-line-tools (clang, make, svn) with something like below.

if [[ -z $(xcodebuild -version) ]]
then
  echo "Found xcodebuild. Checking accepted license."
  if [[ -z $(sudo xcodebuild -license) ]]
  then
    "Could not check if license is accepted. Are you sudo? Skipping check."
  fi
else
  echo "xcodebuild not found. Trying to install.. (mechanism only works on 10.9+)"
  sudo xcode-select --install
  sleep 1
  osascript <<EOD
    tell application "System Events"
      tell process "Install Command Line Developer Tools"
        keystroke return
        click button "Agree" of window "License Agreement"
      end tell
    end tell
  EOD
  sudo xcodebuild -license || echo "Cannot accept XCode license. XCode install not successful? Do you have sudo permissions?"
fi
