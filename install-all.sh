#!/bin/bash
#

set -e

if [ -z "${NO_CLEAN}" ]; then
  echo -n 'Cleaning previous install ... '
  sudo yum remove -y jdg jdg-node1 jdg-node2 jdg-node3 > /dev/null 2> /dev/null
  sudo rm -f /etc/init.d/jdg*
  sudo rm /etc/jdg/*
  for i in {1..3}
  do
    init_script="/etc/init.d/jdg-node-${node_id}"
    if [ -e ${init_script} ]; then
      sudo "${init_script}" 'stop'
    fi
  done
  echo 'Done'
fi

if [ -z "${NO_INSTALL}" ]; then
  echo -n 'Installing new packages... '
  readonly RPMS_DIR='RPMS/noarch/'
  readonly RPMS_LIST='jdg-6.1-1.fc18.noarch.rpm
  jdg-node1-1.0-1.fc18.noarch.rpm
  jdg-node2-1.0-1.fc18.noarch.rpm
  jdg-node3-1.0-1.fc18.noarch.rpm'
  packages=""
  for rpm in ${RPMS_LIST}
  do
      packages="${packages} ${RPMS_DIR}/${rpm}"
  done
  sudo yum install '-y' ${packages}
  echo 'Done'.
fi
