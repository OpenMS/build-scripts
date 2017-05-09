# Wildmagic, CoinOr and the old seqan version 1.4 are not in the standard repos.
# Always build with contrib.
## TODO find a way to choose subset

# If not installed through contrib
# libzip might actually not be necessary but it is very small
sudo yum -y install     boost-devel\
                        libsvm-devel \
                        glpk-devel \
                        libzip-dev \
                        zlib-devel \
                        xerces-c-devel \
                        sqlite-devel \
                        bzip2-devel >> $LOG_PATH/packages.log 2>&1
