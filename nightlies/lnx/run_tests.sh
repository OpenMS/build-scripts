#!/bin/bash
BASE=/group/ag_abi/OpenMS/nightly-builds/
LOG=${BASE}logs
GLOBAL_SCRIPTS=${BASE}scripts/
SCRIPT_DIR=${GLOBAL_SCRIPTS}HEAD
RELEASE_SCRIPT=${GLOBAL_SCRIPTS}RELEASE_BRANCH

# get the machine
EXPECTED_ARGS=1
if [ $# -ne $EXPECTED_ARGS ]
then
	echo "Please give the machine where you want to run the builds on."
	echo "Usage: `basename $0` {machine}"
	exit 1
fi
machine=$1


# sleep to so we do not get problems with concurrent "svn update"s
SLEEP="sleep 300"

# add search engine executables to the PATH
SEARCH_ENGINE_DIR=${BASE}SEARCHENGINES

# add omssa
export PATH=${SEARCH_ENGINE_DIR}/OMSSA:${PATH}
# add xtandem
export PATH=${SEARCH_ENGINE_DIR}/XTandem:${PATH}
# add myrimatch
export PATH=${SEARCH_ENGINE_DIR}/MyriMatch:${PATH}
# add Fido
export PATH=${SEARCH_ENGINE_DIR}/Fido:${PATH}
# add msgfplus
export PATH=${SEARCH_ENGINE_DIR}/MSGFPlus:${PATH}

echo "Finding scripts in ${SCRIPT_DIR} .. "
scripts=$(find ${SCRIPT_DIR} -name "*.cmake" -and -name "${machine}*" -and ! -name "global.cmake")
echo "Finding scripts in ${SCRIPT_DIR} .. done"

echo "Testing is performed on following scripts:"
echo "${scripts}"

I=0
for test_script in $scripts;
do
  filename=$(basename "${test_script}")
  testid="${filename%.*}"

#${SLEEP}
#	ctest -S ${test_script} -V > ${LOG}/${TIMESTAMP}_${testid} 2>&1 &
  TIMESTAMP=$(date +"%Y-%m-%d-%T")
	if [ $I -eq 0 ]; then
		ctest -S ${test_script} -V > ${LOG}/${TIMESTAMP}_${testid} 2>&1
		let I=1
	elif [ $I -eq 1 ]; then
		ctest -S ${test_script} -V > ${LOG}/${TIMESTAMP}_${testid} 2>&1 &
		let I=2
	elif [ $I -eq 2 ]; then
	  ctest -S ${test_script} -V > ${LOG}/${TIMESTAMP}_${testid} 2>&1 &
		let I=3
	elif [ $I -eq 2 ]; then
		ctest -S ${test_script} -V > ${LOG}/${TIMESTAMP}_${testid} 2>&1 &
		let I=4
	else
		ctest -S ${test_script} -V > ${LOG}/${TIMESTAMP}_${testid} 2>&1
		let I=1
	fi

	# wait a bit before starting the next iteration so we do not get problems
	# with svn update
	${SLEEP}
done
#exit 1

# kill xservers
${GLOBAL_SCRIPTS}killorphanedxvncservers

echo "Cleaning old log files .. "
find ${LOG}/* -mtime +5 -exec rm {} \;
echo "Cleaning old log files .. done"
