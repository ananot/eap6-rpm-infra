#!/bin/bash
#
#

# External global variables - can be tweak or overridden by user


readonly JDG_PROPERTIES_FILE=${JDG_PROPERTIES_FILE:-'./jdg.properties'}
readonly JON_PROPERTIES_FILE=${JDG_PROPERTIES_FILE:-'./jon.properties'}
readonly SPECS_FOLDER=${SPECS_FOLDER:-'./SPECS'}

usage() {
  echo "TODO"
  echo ''
}


filter_specfile() {
  local spec_file=${1}
  local field_name=${2}
  local field_value=${3}

  sed -e "s;^\(%define ${field_name}\).*$;\1 ${field_value};g" \
       -i "${spec_file}"
}

generate_spec_files() {
  local spec_tmpl=${1}
  local spec_fullpath=${2}

  echo -n "- generate $(basename ${spec_fullpath}) based on template ${spec_tmpl}..."
  mkdir -p $(dirname ${2})
  cp "${spec_tmpl}" "${spec_fullpath}"
  for line in $(cat ${JDG_PROPERTIES_FILE})
  do
      filter_specfile "${spec_fullpath}" \
                      "$(echo ${line} | cut -d= -f1)" \
                      "$(echo ${line} | cut -d= -f2)"
  done
  echo 'Done.'

}

if [ -z "${JDG_PROPERTIES_FILE}" ]; then
  echo "The variable JDG_PROPERTIES_FILE is not set."
  exit 1
fi

if [ ! -e "${JDG_PROPERTIES_FILE}" ]; then
  echo "The variable JDG_PROPERTIES_FILE does not refer to an existing file:${JDG_PROPERTIES_FILE}"
  exit 2
fi

set -e

echo "Generate SPEC files for JDG binary files install."
spec_tmpl='templates/jdg.tmpl.spec'
generate_spec_files "${spec_tmpl}" \
  "${SPECS_FOLDER}/$(basename ${spec_tmpl} | sed -e 's/.tmpl//')"
echo "SPEC files generation finished, files generated in ${SPECS_FOLDER}."
echo ''

nb_instances=3
echo "Building RPMS for each local instance of JDG (${nb_instances} instances)."
for node_id in {1..3}
do
  export NODE_ID=${node_id}
  sed -e "s/^\(node_id\).*$/\1=${NODE_ID}/g" -i "${JDG_PROPERTIES_FILE}"
  spec_tmpl='templates/jdg-node.tmpl.spec'
  generate_spec_files "${spec_tmpl}" \
    "${SPECS_FOLDER}/$(basename ${spec_tmpl} | sed -e "s/.tmpl/${NODE_ID}/")"
done
# reset NODE_ID to 'XXX' to play nice with version tracking system
sed -e "s/^\(node_id\).*$/\1=XXX/g" -i "${JDG_PROPERTIES_FILE}"
echo "SPEC files for each local node generated in ${SPECS_FOLDER}."

