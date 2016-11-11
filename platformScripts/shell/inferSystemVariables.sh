sourceHere utilityFunctions.sh
OPSYS_detect
sourceHere $OPSYS/inferSystemVariables.sh
## Should work on almost all distros
export ARCH=$(uname -m | sed 's/x86_/x/;s/i[3-6]86/x86/')
export ARCH_NO_BIT=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
export SYSTEM_ID=${SUBDISTRO_NAME}_${SUBDISTRO_VERSION}_${ARCH}

echo "Inferred $OPSYS $DISTRO $SUBDISTRO $SUBDISTRO_NAME $SUBDISTRO_VERSION $ARCH $ARCH_NO_BIT"
