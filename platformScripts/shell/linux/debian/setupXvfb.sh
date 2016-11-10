sudo apt-get -y install xvfb >> $LOG_PATH/packages.log 2>&1
## Careful: This assumes it runs on docker images with a Xvfb installed and that are freshly booted (i.e. no Xserver running on 1)
Xvfb :1 -screen 0 1024x768x24 2>$LOG_PATH/XServer.log &

export DISPLAY=":1"

## To close the Xserver before the script ends
function finish {
  kill -s 15 $(cat /tmp/.X1-lock)
}
trap finish EXIT
