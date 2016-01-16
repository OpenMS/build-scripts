#!/bin/bash -l

umask 002

SCRIPT_PATH=`dirname $0`

# load path options
source ${SCRIPT_PATH}/config.sh

function git_update {
	  pushd $1
		git fetch
		git merge --ff-only origin/$2
		popd
}

# update Fido
git_update ${FIDO_PATH} master

pushd ${FIDO_BUILD_PATH}

CXX=${CXX_COMPILER} CC=${C_COMPILER} cmake ${FIDO_PATH}
make
cp Fido ${SEARCHENGINES}/Fido/
cp FidoChooseParameters ${SEARCHENGINES}/Fido/
popd

# update OpenMS
git_update ${OPENMS_PATH} master

pushd ${BUILD_PATH}

CXX=${CXX_COMPILER} CC=${C_COMPILER} cmake -D CMAKE_PREFIX_PATH=${CONTRIB} \
			-D ENABLE_PREPARE_KNIME_PACKAGE=On \
			-D SEARCH_ENGINES_DIRECTORY=${SEARCHENGINES} \
			-D QT_QMAKE_EXECUTABLE=/group/ag_abi/OpenMS/qt/4.8.6_gcc44/bin/qmake \
			-D CMAKE_CXX_COMPILER=${CXX_COMPILER} \
			-D CMAKE_C_COMPILER=${C_COMPILER} \
			${OPENMS_PATH}


make -j14 prepare_knime_package

if [ "$?" -gt "0" ]; then
	echo "Failed to prepare knime package"
	exit -1
fi

popd

/usr/bin/rsync -avz ${BUILD_PATH}/ctds/ ${TARGET_PATH}/
