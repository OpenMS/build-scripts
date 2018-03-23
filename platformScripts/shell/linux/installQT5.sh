sourceHere $DISTRO/installQT5.sh
if [ -z ${QT_ROOT+x} ] ## if QT_ROOT is not set by distro specifics we assume it is in usual /usr
  then 
  export QT_ROOT=/usr
fi

