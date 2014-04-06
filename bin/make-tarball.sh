#!/bin/bash
#
#

readonly SOURCES_TO_TAR="${HOME}/jboss-webserver-2.0.1
${HOME}/httpd-init-script
${HOME}/jboss-eap-6.0.1/
${HOME}/postgres/
${HOME}/jboss-patches/"

readonly SOURCES_FOLDER=${SOURCES_FOLDER:-'SOURCES'}

readonly TAR_CMD=${TAR_CMD:-'tar'}

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
  local name=${2}
  local target=${3}

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

for target in ${SOURCES_TO_TAR}
do 
  make_tarball "${target}" "$(basename ${target})" "${SOURCES_FOLDER}"
done
