#python2.7 is std on Mac
if ! [ -x "$(command -v pip)" ]
  then
  curl -O https://bootstrap.pypa.io/get-pip.py
  python get-pip.py --user
fi
