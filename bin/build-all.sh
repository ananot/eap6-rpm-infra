#!/bin/bash
#
#

readonly BIN_DIR=$(dirname ${0})

echo 'Step 1 - Generate specfiles based on template.'
${BIN_DIR}/generate-specs.sh

echo 'Step 2 - Synchronise, if needed, source binaries with BUILDROOT.'
${BIN_DIR}/make-tarball.sh

echo 'Step 3 - Build RPMS'
${BIN_DIR}/build-rpms.sh
