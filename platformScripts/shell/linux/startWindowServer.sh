if [[ -z $DISPLAY ]]
  then
    tick "Installing and starting virtual X-Server"
    source setupXvfb.sh
  else
    echo "Window System running on Display $DISPLAY. Using this.."
fi
