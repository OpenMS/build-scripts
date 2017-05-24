if [[ -z $QT_VERSIONS_PATH ]]
  then
  echo "WARNING: On Windows slaves, we currently require a prebuilt QT in a subfolder of the folder set in the QT_VERSIONS_PATH variable."
  echo "Please install or build QT there and name the subfolder like this: qt-\${QT_VERSION}-vs\${VS_YEAR}-(32|64)bit."
  echo "Then set the QT_VERSIONS_PATH on a slave level by configuring the slave in Jenkins."
else
  echo "Searching for matching subfolder in $QT_VERSIONS_PATH"
  export QT_QMAKE_BIN_PATH=$(/usr/bin/find $(cygpath -m $QT_VERSIONS_PATH) -maxdepth 1 -type d -name "qt-4.8*-vs${VS_YEAR}-${ARCH_NO_BIT}bit" | head -1)/bin
  echo "Found matching QT bin dir at: $QT_QMAKE_BIN_PATH"
fi
