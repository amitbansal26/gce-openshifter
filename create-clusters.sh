#!/bin/bash

#
# Usage : ./create-clusters.sh <YAML_CFG> <INSTANCES> <GCP_JSON_FILE> <PROJECT_ID> <KEY_FILE>
# e.g. ./create-clusters.sh vm 10 demo-384301dab612.json stellar-spark-169312 openshift-key
#

FILE=${1:-vm}
INSTANCES={2:-10}
GCP_JSON=$3
PROJECT=$4
KEY=$4

for i in {1..$INSTANCES}; do
  VM_NAME="vm-$i"
  sed -e "s/\<NAME\>/$VM_NAME/g" -e "s/\<PROJECT\>/$PROJECT/g" -e "s/\<KEY\>/$KEY/g" -e "s/\<GCP_JSON\>/$GCP_JSON/g" cluster.tmpl > $FILE-$i.yml
  docker run -ti -v $(pwd):/root/data docker.io/osevg/openshifter:15 create $FILE-$i.yml
done


current=$(pwd)