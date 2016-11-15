if [[ -z $QT_VERSIONS_PATH ]]
  then
  echo "On Windows slaves, we currently require a prebuilt QT in a subfolder of the folder set in the QT_VERSIONS_PATH variable."
  echo "Please install or build QT there and name the subfolder like this: qt-\${QT_VERSION}_vs\${VS_INTERNALVERSION}_(32|64)bit."
  echo "Then set the QT_VERSIONS_PATH on a slave level by configuring the slave in Jenkins."
else
  echo "Searching for matching subfolder in $QT_VERSIONS_PATH"
  export QT_QMAKE_BIN_PATH=$(find $(cygpath -m $QT_VERSIONS_PATH) -type d -name "qt-4*_vs${VS_NR}_${ARCH_NO_BIT}bit" | head -1)/bin
  echo "Found matching QT bin dir at: $QT_QMAKE_BIN_PATH"
fi
