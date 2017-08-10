if [[ -z $QT_VERSIONS_PATH ]]
  then
  echo "WARNING: On Windows slaves, we currently require a prebuilt QT in a subfolder of the folder set in the QT_VERSIONS_PATH variable."
  echo "Please install or build QT there and name the subfolder like this: qt-\${QT_VERSION}-vs\${VS_YEAR}-(32|64)bit."
  echo "Then set the QT_VERSIONS_PATH on a slave level by configuring the slave in Jenkins. Please use mixed cygpath representation,"
  echo " e.g., C:/dev/qt-builds"
else
  echo "Searching for matching subfolder in $QT_VERSIONS_PATH"
  if [[ ${GIT_BRANCH} =~ .*qt5.* ]]
  then
    ## We can be more specific in the future
    QTVER=5
  else
    QTVER=4
  fi
  tmp_qt_path=$(/usr/bin/find $(cygpath -m $QT_VERSIONS_PATH) -maxdepth 1 -type d -name "qt-${QTVER}*-vs${VS_YEAR}-${ARCH_NO_BIT}bit" | head -1)
  if [ ! -z "$tmp_qt_path" ]
  then
    export QT_QMAKE_BIN_PATH="${tmp_qt_path}/bin"
    echo "Found matching QT bin dir at: $QT_QMAKE_BIN_PATH"
  else
    echo "No matching QT directory found. Exiting! Set QT_VERSIONS_PATH in the node settings in Jenkins and have subfolders of the form: qt-\${QTVER}*-vs\${VS_YEAR}-\${ARCH_NO_BIT}bit" && exit 1
  fi
fi
