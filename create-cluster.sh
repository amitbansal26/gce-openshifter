#!/bin/bash

file=${1:-cluster01}

if [ ! -d "openshift-ansible" ]; then
  git clone git@github.com:openshift/openshift-ansible.git
  cd openshift-ansible
  git checkout release-1.5
  cd ..
fi

current=$(pwd)
docker run -ti -v $(pwd):/root/data docker.io/osevg/openshifter create $file