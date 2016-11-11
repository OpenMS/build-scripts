latestJavaJDK=$(sudo yum list java-*-openjdk-devel | grep "java-.*-openjdk.*" | cut -d' ' -f1 | sort | tail -1)
sudo yum -y install $latestJavaJDK >> $LOG_PATH/packages.log 2>&1
