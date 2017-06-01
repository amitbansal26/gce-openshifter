#!/bin/bash

#
# Usage : ./create-clusters.sh YAML_CFG GCP_JSON_FILE PROJECT_ID KEY_FILE
# e.g. ./create-clusters.sh vm demo-384301dab612.json stellar-spark-169312 openshift-key
#

FILE=${1:-vm}
GCP_JSON=$2
PROJECT=$3
KEY=$4

for i in {1..10}; do
  VM_NAME="vm-$i"
  sed -e "s/\<NAME\>/$VM_NAME/g" -e "s/\<PROJECT\>/$PROJECT/g" -e "s/\<KEY\>/$KEY/g" -e "s/\<GCP_JSON\>/$GCP_JSON/g" cluster.tmpl > $FILE-$i.yml
  docker run -ti -v $(pwd):/root/data docker.io/osevg/openshifter:15 create $FILE-$i.yml
done


current=$(pwd)