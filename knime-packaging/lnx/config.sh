OPENMS_PATH=/group/ag_abi/OpenMS/knime_packaging/OpenMS-Release
BUILD_PATH=/buffer/ag_abi/knime_packaging/OpenMS/OpenMS-build
TARGET_PATH=aiche@microcebus.imp.fu-berlin.de:/Users/aiche/KNIME_PACKAGING/assembly/lnx
SEARCHENGINES=/group/ag_abi/OpenMS/knime_packaging/SEARCHENGINES
CONTRIB=/group/ag_abi/OpenMS/contrib/build/gcc/
FIDO_PATH=/group/ag_abi/OpenMS/Fido
FIDO_BUILD_PATH=/group/ag_abi/OpenMS/Fido/build/gcc/

# if you change the compiler you need to rebuild from scratch
# e.g., rm -rf ${BUILD_PATH}
CXX_COMPILER="/usr/bin/g++"
C_COMPILER="/usr/bin/gcc"
