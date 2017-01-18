if [[ -z $DISPLAY ]]
  then
    tick "Setting up virtual X-Server"
    source setupXvfb.sh
    tock
  else
  echo "Window System running on Display $DISPLAY. Using this.."
fi
