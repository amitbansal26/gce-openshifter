#!/bin/bash

file=${1:-cluster01}

current=$(pwd)
docker run -ti -v $(pwd):/root/data docker.io/osevg/openshifter:15 destroy $file