#${OPENMS_BREW_FOLDER}/bin/brew tap cartr/qt4
#${OPENMS_BREW_FOLDER}/bin/brew install qt@4
#${OPENMS_BREW_FOLDER}/bin/brew install qt-webkit@2.3
## First line is for older brews where qt was still qt4. Will be overridden if the newer custom packages exist
${OPENMS_BREW_FOLDER}/bin/brew --prefix qt && export QT_ROOT="$(${OPENMS_BREW_FOLDER}/bin/brew --prefix qt)"
${OPENMS_BREW_FOLDER}/bin/brew --prefix qt@4 && export QT_ROOT="$(${OPENMS_BREW_FOLDER}/bin/brew --prefix qt@4)"
${OPENMS_BREW_FOLDER}/bin/brew --prefix qt-webkit@2.3 && export QT_WEBKIT_ROOT="$(${OPENMS_BREW_FOLDER}/bin/brew --prefix qt-webkit@2.3)"
