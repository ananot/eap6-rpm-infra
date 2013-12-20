#!/bin/bash

for node in /etc/init.d/jdg-node*
do
  instance_name=$(basename ${node})
  if [ -z "${NO_STOP}" ]; then
    echo "Stopping ${instance_name}."
    sudo "${node}" 'stop'
  fi

  if [ -z "${NO_START}" ]; then
    echo "Starting ${instance_name}."
    sudo "${node}" 'start' > /dev/null 2> /dev/null &
  fi
done
#tail -f /var/log/jdg/node-*.log
