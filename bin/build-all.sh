#!/bin/bash
#
#

readonly BIN_DIR=$(dirname ${0})

echo 'Step 1 - Build tarball.'
${BIN_DIR}/make-tarball.sh

echo 'Step 2 - Build RPMS'
${BIN_DIR}/build-rpms.sh
