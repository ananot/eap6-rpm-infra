#!/bin/bash
#
#

# External global variables - can be tweak or overridden by user

readonly JDG_REPOSITORY=${JDG_REPOSITORY}
readonly JON_REPOSITORY=${JON_REPOSITORY}

readonly JDG_PROPERTIES_FILE=${JDG_PROPERTIES_FILE:-'./jdg.properties'}
readonly JON_PROPERTIES_FILE=${JDG_PROPERTIES_FILE:-'./jon.properties'}
readonly SPECS_FOLDER=${SPECS_FOLDER:-'./SPECS'}

# Internal global variables

# readonly BUILDROOT="--buildroot ${HOME}/rpmbuild/BUILDROOT"     # only required if running on "older" system (RHEL5)
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

filter_specfile() {
  local spec_file=${1}
  local field_name=${2}
  local field_value=${3}

  sed -e "s;^\(%define ${field_name}\).*$;\1 ${field_value};g" \
       -i "${spec_file}"
}

prepare_and_build_rpm() {
  local src=${1}
  local target=${2}
  local spec_tmpl=${3}
  local spec_fullpath=${4}

  if [ ! -e "${src}" ]; then
    echo "Source folder ${src} does not exist, skipping sync... Done."
  else
    mkdir -p "${target}"

    echo -n "Syncing from ${src} to ${2} ... "
    ${RSYNC_CMD} -Arvcz ${src}/* "${target}" > /dev/null
    echo 'Done.'
  fi

  echo -n "Filter spec file template ${spec_tmpl} ... "
  cp "${spec_tmpl}" "${spec_fullpath}"
  for line in $(cat ${JDG_PROPERTIES_FILE})
  do
      filter_specfile "${spec_fullpath}" \
                      "$(echo ${line} | cut -d= -f1)" \
                      "$(echo ${line} | cut -d= -f2)"
  done
  echo 'Done.'

  build_rpm "${spec_fullpath}"
}

build_rpm() {
  local spec_fullpath=${1}

  echo -n "Building RPM from ${spec_fullpath} ... "
  ${RPMBUILD_CMD} '-bb' "${spec_fullpath}" "${BUILDROOT}" > /dev/null 2> /dev/null
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

if [ -z "${JDG_PROPERTIES_FILE}" ]; then
  echo "The variable JDG_PROPERTIES_FILE is not set."
  exit 4
fi

if [ ! -e "${JDG_PROPERTIES_FILE}" ]; then
  echo "The variable JDG_PROPERTIES_FILE does not refer to an existing file:${JDG_PROPERTIES_FILE}"
  exit 5
fi

set -e

echo "Building RPM for JDG binary files install from JDG repository: ${JDG_REPOSITORY}."
spec_tmpl='templates/jdg.tmpl.spec'
prepare_and_build_rpm "${JDG_REPOSITORY}" \
          "./BUILDROOT/jdg-6.1-1.fc18.x86_64/opt/jboss/jboss-datagrid-6.1" \
          "${spec_tmpl}" \
          "${SPECS_FOLDER}/$(basename ${spec_tmpl} | sed -e 's/.tmpl//')"
echo "RPM binary files build finished."
echo ''

nb_instances=3
echo "Building RPMS for each local instance of JDG (${nb_instances} instances)."
for node_id in {1..3}
do
  export NODE_ID=${node_id}
  sed -e "s/^\(node_id\).*$/\1=${NODE_ID}/g" -i "${JDG_PROPERTIES_FILE}"
  spec_tmpl='templates/jdg-node.tmpl.spec'
  prepare_and_build_rpm '/no/sync/folder' \
          "/dev/null" \
          "${spec_tmpl}" \
          "${SPECS_FOLDER}/$(basename ${spec_tmpl} | sed -e "s/.tmpl/${NODE_ID}/")"
done
# reset NODE_ID to 'XXX' to play nice with version tracking system
sed -e "s/^\(node_id\).*$/\1=XXX/g" -i "${JDG_PROPERTIES_FILE}"

echo "RPMS build for each local instance of JDG finished"
echo ''

if [ -z "${JON_REPOSITORY}" ]; then
    echo "No JON repository configured - skipping JON packaging... Done"
else
  echo "Builidng RPM for JBoss Network Operation"
  spec_tmpl='templates/jon.tmpl.spec'
  prepare_and_build_rpm "${JDG_REPOSITORY}" \
            "./BUILDROOT/jon-6.1-1.fc18.x86_64/opt/jboss/jboss-datagrid-6.1" \
            "${spec_tmpl}" \
            "${SPECS_FOLDER}/$(basename ${spec_tmpl} | sed -e 's/.tmpl//')"
  echo "RPM build for JON finished."
  echo ''
fi
