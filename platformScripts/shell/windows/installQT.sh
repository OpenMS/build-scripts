#TODO Require QT_VERSIONS_DIR and look for fitting subfolder using bash
# Then set QMAKE_BIN_DIR
if [[ -z $QT_VERSIONS_DIR ]]
  then
  echo "On Windows slaves, we currently require a prebuilt QT in a subfolder of the folder set in the QT_VERSIONS_DIR variable."
  echo "Please install or build QT there and name the subfolder like this: qt-\${VERSION}_vs\${VS_INTERNALVERSION}_\(32|64\)bit."
  echo "Then set the QT_VERSIONS_DIR on a slave level by configuring the slave in Jenkins."
else
  export QT_QMAKE_BIN_DIR=$(ls $(cygpath -m $QT_VERSIONS_DIR)/qt-4*_vs${VS_NR}_${ARCH_NO_BIT}bit | head)/bin
  echo "Found matching QT bin dir at: $QT_QMAKE_BIN_DIR"
fi
