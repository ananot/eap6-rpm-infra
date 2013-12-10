#!/bin/bash
#
#

# External global variables - can be tweak or overridden by user
readonly SPECS_FOLDER=${SPECS_FOLDER:-'./SPECS'}

# Internal global variables

readonly RPMBUILD_CMD=${RPMBUILD_CMD:-'rpmbuild'}

usage() {
  echo "TODO"
  echo ''
}

sanity_check() {
  local cmd=${1}

  which "${cmd}" 2> /dev/null > /dev/null
  status=${?}
  if [ ${status} -ne 0 ]; then
    echo "This script requires the command ${cmd}, please install it before running it."
    exit ${status}
  fi
}

build_rpm() {
  local spec_fullpath=${1}

  echo -n "  - Building RPM from ${spec_fullpath} ... "
  ${RPMBUILD_CMD} '-bb' "${spec_fullpath}" > /dev/null 2> /dev/null
  echo 'Done.'
}

sanity_check ${RPMBUILD_CMD}


echo "Building RPMS from each jdg* SPECS in ${SPECS_FOLDER}/"
for specfile in ${SPECS_FOLDER}/jdg*
do
  build_rpm "${specfile}"
done
echo ''

if  [ -e ${SPECS_FOLDER}/jon-*.rpm ] ; then
  echo "Builidng RPM for JBoss Network Operation"
  build_rpm ${SPECS_FOLDER}/jon-*.rpm
  echo "RPM build for JON finished."
  echo ''
fi
