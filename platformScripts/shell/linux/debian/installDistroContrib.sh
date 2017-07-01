# If not installed through contrib
# libzip might actually not be necessary but it is very small
sudo apt-get -y install libboost-regex-dev libboost-iostreams-dev libboost-date-time-dev libboost-math-dev \
                        coinor-cbc coinor-libclp-dev coinor-libcbc-dev coinor-libosi-dev coinor-libvol-dev coinor-libcgl-dev \ 
                        libsvm-dev \
                        seqan-dev \ ##TODO seqan 1.4 first available in 16.04 (build in contrib otherwise)
                        libglpk-dev \
                        libzip-dev \
                        zlib1g-dev \
                        libxerces-c-dev \
                        libsqlite3-dev \
                        libwildmagic-dev \ ##TODO first available in 16.04 (build in contrib otherwise)
                        libbz2-dev >> $LOG_PATH/packages.log 2>&1
