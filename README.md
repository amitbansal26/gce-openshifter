# Create GCP Vm & install OpenShift

* Install Google Cloud SDK

Download doc [SDK](https://cloud.google.com/sdk/downloads) 
Enter the following at a command prompt:
```
curl https://sdk.cloud.google.com | bash

# Restart your shell:
exec -l $SHELL

# Run gcloud init to initialize the gcloud environment:
gcloud init
```

* Update it (optional) and install alpha

```
gcloud components update
gcloud components install alpha
```

* Check your billing ID

```
gcloud alpha billing accounts list
ID                    NAME                OPEN
002916-AD0F6B-54058C  My Billing Account  True
```

* Create project 

Script : https://medium.com/google-cloud/how-to-automate-project-creation-using-gcloud-4e71d9a70047

```
curl -O https://raw.githubusercontent.com/GoogleCloudPlatform/training-data-analyst/master/blogs/gcloudprojects/create_projects.sh
chmod +x create_projects.sh
./create_projects.sh 002916-AD0F6B-54058C workshop cmoulliard@redhat.com

Creating project workshop-1-cmoulliardxredhatxc for cmoulliard@redhat.com ...
Create in progress for [https://cloudresourcemanager.googleapis.com/v1/projects/workshop-1-cmoulliardxredhatxc].
Waiting for [operations/pc.8781693343462747897] to finish...done.
Updated IAM policy for project [workshop-1-cmoulliardxredhatxc].
bindings:
- members:
  - user:cmoullia@redhat.com
  role: roles/editor
- members:
  - user:cmoullia@redhat.com
  role: roles/owner
etag: BwVQ4dJeMMg=
version: 1
billingAccountName: billingAccounts/002916-AD0F6B-54058C
billingEnabled: true
name: projects/workshop-1-cmoulliardxredhatxc/billingInfo
projectId: workshop-1-cmoulliardxredhatxc

gcloud projects list
PROJECT_ID                      NAME                            PROJECT_NUMBER
stellar-spark-169312            demo                            182007403298
workshop-1-cmoulliardxredhatxc  workshop-1-cmoulliardxredhatxc  733040473908
```

* Create Project (manual)

```
gcloud projects create workshop-cmoulliard-redhat-com
```

* Delete project

```
gcloud projects delete workshop-cmoulliard-redhat-com
```

* Add a Service Account

```
gcloud iam service-accounts list
gcloud iam service-accounts keys create \
    ~/key.json \
    --iam-account <SA_ID>@<PROJECT_ID>.iam.gserviceaccount.com
gcloud iam service-accounts keys create \
    ~/key.json \
    --iam-account my-sa-1@stellar-spark-169312.iam.gserviceaccount.com    
```

<PROJECT_ID> : "stellar-spark-169312"
<SA_ID> : "my-sa-123"

* Create Cloud DNS Zone (e.g. nip name for fomain nip.io.)

```
gcloud config set project stellar-spark-169312

gcloud dns managed-zones create --dns-name="nip.io." --description="NIP.IO Domain" "nip"

gcloud dns managed-zones list
NAME  DNS_NAME  DESCRIPTION
nip   nip.io.

gcloud dns managed-zones describe nip
creationTime: '2017-06-01T07:47:00.431Z'
description: NIP.IO Domain
dnsName: nip.io.
id: '3007714338857919627'
kind: dns#managedZone
name: nip
nameServers:
- ns-cloud-c1.googledomains.com.
- ns-cloud-c2.googledomains.com.
- ns-cloud-c3.googledomains.com.
- ns-cloud-c4.googledomains.com.
```

* Create a new Service Account with Project Owner role, and furnish a new JSON key
* To enable Google Compute Engine API

Open this link in your browser and clik on the link "Enable API"

https://console.developers.google.com/apis/api/compute-component.googleapis.com/overview?project=stellar-spark-169312

# To clean some GCP resources not deleted

gcloud compute disks delete cluster01-master-docker --quiet
gcloud compute addresses delete cluster01-master --quiet

gcloud compute firewall-rules delete firewall-internal --quiet
gcloud compute firewall-rules delete firewall-master --quiet
gcloud compute firewall-rules delete firewall-all --quiet
gcloud compute firewall-rules delete firewall-infra --quiet
gcloud compute firewall-rules delete cluster01-allow-http --quiet
gcloud compute firewall-rules delete cluster01-allow-https --quiet

gcloud compute networks delete cluster01 --quiet

# Create VM

./create-cluster.sh cluster01
