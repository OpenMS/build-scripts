# Wildmagic, CoinOr and the old seqan version 1.4 are not in the standard repos.
# Always build with contrib.
## TODO find a way to choose subset

# If not installed through contrib
# libzip might actually not be necessary but it is very small
sudo apt-get -y install libboost-regex-dev libboost-iostreams-dev libboost-date-time-dev libboost-math-dev \
                        libsvm-dev \
                        libglpk-dev \
                        libzip-dev \
                        zlib1g-dev \
                        libxerces-c-dev \
                        libsqlite3-dev \
                        libbz2-dev >> $LOG_PATH/packages.log 2>&1
