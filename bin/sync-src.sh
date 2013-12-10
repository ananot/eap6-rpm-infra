#!/bin/bash
#
#

# External global variables - can be tweak or overridden by user

readonly JDG_REPOSITORY=${JDG_REPOSITORY}
readonly JON_REPOSITORY=${JON_REPOSITORY}

readonly JDG_BUILDROOT=${JDG_BUILDROOT:-"./BUILDROOT/jdg-6.1-0.fc18.x86_64/opt/jboss/jboss-datagrid-6.1"}
readonly JON_BUILDROOT=${JON_BUILDROOT:-"./BUILDROOT/jon-6.1-1.fc18.x86_64/opt/jboss/jboss-operation-network-3.1.2"}

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
  local name=${3}

  if [ -z "${src}" ]; then
    echo "No source directory provided for ${name} - skipping... Done."
  else

    if [ ! -d ${src} ]; then
      echo "Source directory is NOT a directory: ${src}."
      exit 1
    fi

    if [ ! -e "${src}" ]; then
      echo "Source folder ${src} does not exist, skipping sync... Done."
    else
      mkdir -p "${target}"

      echo -n "Syncing from ${src} to ${2} ... "
      ${RSYNC_CMD} -Arvcz ${src}/* "${target}" > /dev/null
      echo 'Done.'
    fi
  fi
}

set -e
sanity_check ${RSYNC_CMD}

sync_src "${JDG_REPOSITORY}" "${JDG_BUILDROOT}" 'JDG'
echo ''
sync_src "${JON_REPOSITORY}" "${JON_BUILDROOT}" 'JON'
