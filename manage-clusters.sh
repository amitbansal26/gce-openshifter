#!/bin/bash

#
# Usage : ./manage-clusters.sh <YAML_CFG> <INSTANCES> <GCP_JSON_FILE> <PROJECT_ID> <KEY_FILE> <CMD>
# where <CMD> command can be : create, provision, install, setup or destroy
# e.g.
# ./manage-clusters.sh vm 10 demo-384301dab612.json stellar-spark-169312 openshift-key create
# ./manage-clusters.sh vm 10 demo-384301dab612.json stellar-spark-169312 openshift-key provision
#

FILE=${1:-vm}
INSTANCES=${2:-10}
GCP_JSON=$3
PROJECT=$4
KEY=$5
CMD=${6:-create}

for ((i=1; i<=INSTANCES; i++)); do
  VM_NAME="$FILE-$i"
  if [ ! -e $FILE-$i.yml ]; then
    sed -e "s/\<NAME\>/$VM_NAME/g" -e "s/\<PROJECT\>/$PROJECT/g" -e "s/\<KEY\>/$KEY/g" -e "s/\<GCP_JSON\>/$GCP_JSON/g" cluster.tmpl > $FILE-$i.yml
  fi
  docker run -ti -v $(pwd):/root/data docker.io/osevg/openshifter:15 $CMD $FILE-$i
done