#${OPENMS_BREW_FOLDER}/bin/brew tap cartr/qt4
#${OPENMS_BREW_FOLDER}/bin/brew install qt@4
#${OPENMS_BREW_FOLDER}/bin/brew install qt-webkit@2.3
export QT_ROOT="$(${OPENMS_BREW_FOLDER}/bin/brew --prefix qt@4);$(${OPENMS_BREW_FOLDER}/bin/brew --prefix qt-webkit@2.3)"
