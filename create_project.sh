#!/bin/bash

# set -x
# trap read debug

if [ "$#" -lt 3 ]; then
   echo "Usage:  ./create_project.sh billingid project_id"
   echo "   eg:  ./create_project.sh 0X0X0X-0X0X0X-0X0X0X workshop-jbcnconf"
   exit
fi

ACCOUNT_ID=$1
shift
PROJECT_ID=$1
shift
REGION="europe-west1"
ZONE="europe-west1-b"
USER="cmoulliard@redhat.com"
SERVICEACCOUNT="my-workshop-sa"

echo "Update gcloud client"
# gcloud components update
# gcloud components install alpha


#PROJECT_ID=$(echo "${PROJECT_PREFIX}-${EMAIL}" | sed 's/@/x/g' | sed 's/\./x/g' | cut -c 1-30)
echo "Creating project $PROJECT_ID ... "
gcloud projects create $PROJECT_ID
sleep 2

echo ">>> Make this project the default"
gcloud config set project $PROJECT_ID

echo ">>> Enable Billing forthe project"
gcloud alpha billing accounts projects link $PROJECT_ID --account-id=$ACCOUNT_ID

echo ">>> Change default location"
gcloud compute project-info add-metadata --metadata google-compute-default-region=$REGION,google-compute-default-zone=$ZONE


echo ">>> Add role owner to the user"
gcloud projects add-iam-policy-binding $PROJECT_ID --member='user:$USER' --role='roles/owner'


echo ">>> Add a Service Account"
gcloud iam service-accounts create $SERVICEACCOUNT --display-name "my-workshop-service-account"
gcloud iam service-accounts keys create ~/key.json --iam-account $SERVICEACCOUNT@$PROJECT_ID.iam.gserviceaccount.com

echo ">>> Give role owner to the serviceaccoutn and bind it to the project"
gcloud iam service-accounts add-iam-policy-binding $SERVICEACCOUNT@$PROJECT_ID.iam.gserviceaccount.com --role='roles/owner' --member='user:$USER'
gcloud projects add-iam-policy-binding $PROJECT_ID --member='serviceAccount:$SERVICEACCOUNT@$PROJECT_ID.iam.gserviceaccount.com' --role='roles/owner'


echo ">>> Enable Services"
gcloud service-management enable cloudbilling.googleapis.com
gcloud service-management enable cloudapis.googleapis.com
gcloud service-management enable dns.googleapis.com
gcloud service-management enable compute-component.googleapis.com
#gcloud service-management enable container.googleapis.com

echo ">>> Create Cloud DNS Zone (e.g. nip name for fomain nip.io.)"

gcloud dns managed-zones create --dns-name="nip.io." --description="NIP.IO Domain" "nip"