#!/bin/bash

if [ "$#" -lt 2 ]; then
   echo "Usage:  ./delete_projects.sh project-prefix"
   echo "   eg:  ./delete_projects.sh workshop-jbcnconf-cmoulliardxr"
   exit
fi

PROJECT_PREFIX=$1

echo "Deleting project $PROJECT_ID"
gcloud projects delete $PROJECT_ID
