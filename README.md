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

* Create Project (manual)

```
gcloud projects create workshop-cmoulliard-redhat-com
```

* Make project as default
```
gcloud config set project workshop-cmoulliard-redhat-com
```

* Change default location
```
gcloud compute project-info add-metadata \
    --metadata google-compute-default-region=europe-west1,google-compute-default-zone=europe-west1-b
```

* Create project (automated)

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

* Delete project

```
gcloud projects delete workshop-cmoulliard-redhat-com
```

* Add role owner to the user 
```
gcloud projects add-iam-policy-binding workshop-cmoulliard-redhat-com --member='user:cmoulliard@redhat.com' --role='roles/owner'
```

* Add a Service Account

To create a service account, run the following command:

```
gcloud iam service-accounts create my-workshop-sa --display-name "my workshop service account"
gcloud iam service-accounts keys create \
    ~/key.json \
    --iam-account <SA_ID>@<PROJECT_ID>.iam.gserviceaccount.com

<PROJECT_ID> : "stellar-spark-169312"
<SA_ID> : "my-sa-123"
    
gcloud iam service-accounts keys create ~/key.json --iam-account my-workshop-sa@workshop-cmoulliard-redhat-com.iam.gserviceaccount.com   
```

* Give role owner

```
gcloud iam service-accounts add-iam-policy-binding my-workshop-sa@workshop-cmoulliard-redhat-com.iam.gserviceaccount.com --role='roles/owner' --member='user:cmoulliard@redhat.com'
gcloud projects add-iam-policy-binding workshop-cmoulliard-redhat-com --member='serviceAccount:my-workshop-sa@workshop-cmoulliard-redhat-com.iam.gserviceaccount.com' --role='roles/owner' 
```


* Enable Billing forthe project

```
gcloud alpha billing accounts projects link workshop-cmoulliard-redhat-com --account-id=002916-AD0F6B-54058C
```

* Enable Services
```
gcloud service-management enable cloudbilling.googleapis.com
gcloud service-management enable cloudapis.googleapis.com
gcloud service-management enable dns.googleapis.com
gcloud service-management enable compute-component.googleapis.com
#gcloud service-management enable container.googleapis.com 
```

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

# Create VM using OpenShifter

This script will start a docker process running `openshifter` to create a VM (RHEL-7) on GCP and install OpenShift Container Platform.
The config is defined within the `cluster01.yml` file

```
./create-cluster.sh cluster01
```

# Tricks

## To clean some GCP resources not deleted

```
gcloud compute disks delete cluster01-master-docker --quiet
gcloud compute addresses delete cluster01-master --quiet

gcloud compute firewall-rules delete firewall-internal --quiet
gcloud compute firewall-rules delete firewall-master --quiet
gcloud compute firewall-rules delete firewall-all --quiet
gcloud compute firewall-rules delete firewall-infra --quiet

gcloud compute firewall-rules delete cluster01-allow-http --quiet
gcloud compute firewall-rules delete cluster01-allow-https --quiet

gcloud compute networks delete cluster01 --quiet

OR

gcloud compute disks delete cluster-wks-01-master-root --quiet
gcloud compute disks delete cluster-wks-01-master-docker --quiet
gcloud compute addresses delete cluster-wks-01-master --quiet
gcloud compute networks delete cluster-wks-01 --quiet
```