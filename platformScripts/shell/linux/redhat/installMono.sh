# Only works on CentOS
rpm --import "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
su -c 'curl https://download.mono-project.com/repo/centos${SUBDISTRO_VERSION}-stable.repo | tee /etc/yum.repos.d/mono-centos${SUBDISTRO_VERSION}-stable.repo'
