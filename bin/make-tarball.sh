#!/bin/bash
#
#

# External global variables - can be tweak or overridden by user

readonly JDG_REPOSITORY=${JDG_REPOSITORY}
readonly JON_REPOSITORY=${JON_REPOSITORY}

readonly JDG_TARBALL_NAME=${JDG_TARBALL_NAME:-'jdg-6.1'}
readonly JON_TARBALL_NAME=${JON_TARBALL_NAME:-'jon-3.1.2'}

readonly SOURCES_FOLDER=${SOURCES_FOLDER:-'SOURCES'}

readonly TAR_CMD=${TAR_CMD:-'tar'}

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

make_tarball() {
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
      echo "Source folder ${src} does not exist, skipping tarball... Done."
      exit 2
    else
      echo -n "Tarball from ${src} to ${2} ... "
      target_fullpath=$(pwd)/${target}
      ln -s "${src}" "${name}"
      ${TAR_CMD} -cvzf "${target}/${name}.tgz" ${name}/* > /dev/null
      rm -f "${name}"
      echo 'Done.'
    fi
  fi
}

sanity_check ${TAR_CMD}
set -e

make_tarball "${JDG_REPOSITORY}" "${SOURCES_FOLDER}" "${JDG_TARBALL_NAME}"
