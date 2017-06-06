#!/bin/bash

if [ "$#" -lt 1 ]; then
   echo "Usage:  ./delete_projects.sh <PROJECT_ID>"
   echo "   eg:  ./delete_projects.sh workshop-jbcnconf-cmoulliardxr"
   exit
fi

PROJECT_ID=$1

echo "Deleting project $PROJECT_ID"
gcloud projects delete $PROJECT_ID --quiet
