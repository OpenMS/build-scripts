latestJavaJRE=$(sudo yum list java-*-openjdk-headless | grep "java-.*-openjdk.*" | cut -d' ' -f1 | sort | tail -1)
sudo yum -y install $latestJavaJRE >> $LOG_PATH/packages.log 2>&1
