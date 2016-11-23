OPSYS_detect
export ARCH=$(uname -m | sed 's/x86_/x/;s/i[3-6]86/x86/')
export ARCH_NO_BIT=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
sourceHere $OPSYS/inferSystemVariables.sh
## Should work on almost all distros
export SYSTEM_ID=${SUBDISTRO_NAME}_${SUBDISTRO_VERSION}_${ARCH}

echo "Inferred:\n OPSYS=$OPSYS \n DISTRO=$DISTRO \n SUBDISTRO=$SUBDISTRO \n SUBDISTRO_NAME=$SUBDISTRO_NAME \n SUBDISTRO_VERSION=$SUBDISTRO_VERSION \n (Native)ARCH=$ARCH \n (Native)ARCH_NO_BIT=$ARCH_NO_BIT \n OPENMS_TARGET_ARCH=$OPENMS_TARGET_ARCH"
