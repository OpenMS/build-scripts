#!/bin/bash

# --------------------------------------------------------------------------
#                   OpenMS -- Open-Source Mass Spectrometry
# --------------------------------------------------------------------------
# Copyright The OpenMS Team -- Eberhard Karls University Tuebingen,
# ETH Zurich, and Freie Universitaet Berlin 2002-2012.
#
# This software is released under a three-clause BSD license:
#  * Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#  * Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#  * Neither the name of any author or any participating institution
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
# For a full list of authors, refer to the file AUTHORS.
# --------------------------------------------------------------------------
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL ANY OF THE AUTHORS OR THE CONTRIBUTING
# INSTITUTIONS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# --------------------------------------------------------------------------
# $Maintainer: Stephan Aiche $
# $Authors: Stephan Aiche $
# --------------------------------------------------------------------------

source /Users/aiche/.profile

# just to be sure latex&co are there
export PATH=$PATH:/usr/texbin

BASE=/Users/aiche/NIGHTLY/
LOG=${BASE}logs
PYOPENMS_DIR=${BASE}scripts/PYOPENMS
RELEASE_DIR=${BASE}scripts/RELEASE
DEVELOP_DIR=${BASE}scripts/HEAD
SCRIPT_DIR=${DEVELOP_DIR}
# sleep to so we do not get problems with concurrent "svn update"s
SLEEP="sleep 30"

# add search engine executables to the PATH
SEARCH_ENGINE_DIR=${BASE}SEARCHENGINES

# add omssa
export PATH=${SEARCH_ENGINE_DIR}/OMSSA:${PATH}
# add xtandem
export PATH=${SEARCH_ENGINE_DIR}/XTandem:${PATH}
# add Fido
export PATH=${SEARCH_ENGINE_DIR}/Fido:${PATH}
# add MSGFPlus
export PATH=${SEARCH_ENGINE_DIR}/MSGFPlus:${PATH}

echo "Finding scripts in ${SCRIPT_DIR} .. "
# add "${RELEASE_DIR}" to find command to enable nightly builds on release branch
scripts=$(find "${SCRIPT_DIR}" -name "*.cmake" ! -name "global.cmake")
echo "Finding scripts in ${SCRIPT_DIR} .. done"

for test_script in $scripts;
do
  filename=$(basename "${test_script}")
  testid="${filename%.*}"
  CONFIG=$(echo $filename | sed -n -e 's/.*-\(Debug\)\.cmake/\1/p' -e 's/.*-\(Release\)\.cmake/\1/p')

  TIMESTAMP=$(date +"%Y-%m-%d-%T")
  echo "[${TIMESTAMP}] ${testid} .. "
  ctest -S ${test_script} -C $CONFIG -V > ${LOG}/${TIMESTAMP}_${testid}.log 2>&1
  TIMESTAMP=$(date +"%Y-%m-%d-%T")
  echo "[${TIMESTAMP}] ${testid} .. done"
done

echo "Cleaning old log files .. "
find ${LOG} -mtime +5 -exec rm {} \;
echo "Cleaning old log files .. done"
