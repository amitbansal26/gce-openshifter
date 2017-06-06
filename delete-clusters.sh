#!/bin/bash

INSTANCES=${1:-10}
current=$(pwd)

for ((i=1; i<=INSTANCES; i++)); do
  VM_NAME="vm-$i"
  docker run -ti -v $(pwd):/root/data docker.io/osevg/openshifter:15 destroy $VM_NAME
done