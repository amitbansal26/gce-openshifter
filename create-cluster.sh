#!/bin/bash

file=${1:-cluster01}

export current=$(pwd)
docker run -ti -v $(pwd):/root/data docker.io/osevg/openshifter:15 create $file