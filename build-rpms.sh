#!/bin/bash
#
#

# External global variables - can be tweak or overridden by user

readonly JDG_REPOSITORY=${JDG_REPOSITORY}
readonly JON_REPOSITORY=${JON_REPOSITORY}

readonly SPECS_FOLDER=${SPECS_FOLDER:-'./SPECS'}

# Internal global variables

readonly RPMBUILD_CMD=${RPMBUILD_CMD:-'rpmbuild'}
readonly RSYNC_CMD=${RSYNC_CMD:-'rsync'}

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

sync_src() {
  local src=${1}
  local target=${2}

  if [ ! -e "${src}" ]; then
    echo "Source folder ${src} does not exist, skipping sync... Done."
  else
    mkdir -p "${target}"

    echo -n "Syncing from ${src} to ${2} ... "
    ${RSYNC_CMD} -Arvcz ${src}/* "${target}" #> /dev/null
    echo 'Done.'
  fi
}

build_rpm() {
  local spec_fullpath=${1}

  echo -n "  - Building RPM from ${spec_fullpath} ... "
  ${RPMBUILD_CMD} '-bb' "${spec_fullpath}" > /dev/null 2> /dev/null
  echo 'Done.'
}

sanity_check ${RPMBUILD_CMD}
sanity_check ${RSYNC_CMD}

if [ -z ${JDG_REPOSITORY} ]; then
  echo "Variable JDG_REPOSITORY not set."
  exit 1
fi

if [ ! -d ${JDG_REPOSITORY} ]; then
  echo "Variable JDG_REPOSITORY does not refer to a directory: ${JDG_REPOSITORY}."
  exit 2
fi

if [ ! -e "${JDG_REPOSITORY}/JBossEULA.txt" ] ; then
  echo "The folder ${JDG_REPOSITORY} does not appears to be an expanded JDG distribution (no JBossEULA.txt found)."
  exit 3
fi

sync_src "${JDG_REPOSITORY}" \
         "./BUILDROOT/jdg-6.1-0.fc18.x86_64/opt/jboss/jboss-datagrid-6.1" \
echo ''

echo "Building RPMS from each jdg* SPECS in ${SPECS_FOLDER}/"
for specfile in ${SPECS_FOLDER}/jdg*
do
  build_rpm "${specfile}"
done

echo "RPMS build for each local instance of JDG finished"
echo ''

if [ -z "${JON_REPOSITORY}" ]; then
    echo "No JON repository configured - skipping JON packaging... Done"
else
  sync_src "${JON_REPOSITORY}" \
           "./BUILDROOT/jon-6.1-1.fc18.x86_64/opt/jboss/jboss-datagrid-6.1"
  echo "Builidng RPM for JBoss Network Operation"
  build_rpm ${SPECS_FOLDER}/jon-*.rpm
  echo "RPM build for JON finished."
  echo ''
fi
