# Create GCP VMs & install OpenShift

In order to create some RHEL or CentOS Virtual Machines (VMs) on Google Cloud Platform and to install OpenShift OCP, it is required to create a [GCP account](https://console.cloud.google.com/freetrial),
next to create a Project which forms the basis for creating, enabling, and using all Cloud Platform services including managing APIs, enabling billing, adding and
removing collaborators, and managing permissions for Cloud Platform resources.

This document describes, using the Google SDK - gcloud client, how such a project can be created, as the service account & keys (OAuth2) which is required to communicate from your machine with the cloud platform
in order to manage the required resources; VMs, APIs, Networks, Firewall rules, ...

The document details how you can achieve this goal using bash shell script or manual instructions executed from a terminal.

## Install Google Cloud SDK

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

## Manual steps

The following steps assume that the `gcloud` client has been installed, that it has been define is on your bin path and that you have initialize it using the command `gcloud init`.

* Check your billing ID

The billing id will be used to link the project with your billable account. This step is mandatory as the billing id will be used next to create 

```
gcloud alpha billing accounts list
ID                    NAME                OPEN
002916-AD0F6B-54058C  My Billing Account  True
```

* Create Project

```
gcloud projects create <PROJECT_ID>
where <PROJECT_ID> is defined according to a prefix + your email address without `. or @` symbols

E.g.
gcloud projects create workshop-cmoulliard-redhat-com
```

* Add role owner to the user 

As your user/email linked to your GCP account will be used to manage the different projects, we recommend to assign it to the project created with the role `owner` using 
a policy binding. With such a role, you will be authorized to manage all the resources using the UI 

```
gcloud projects add-iam-policy-binding <PROJECT_ID> --member='user:<EMAIL>' --role='roles/owner'
E.g.
gcloud projects add-iam-policy-binding workshop-cmoulliard-redhat-com --member='user:cmoulliard@redhat.com' --role='roles/owner'
```

* Make project as default

If you have already created different Google Cloud Platform projects, then it is required to tell to GCP that the newly project created is the default now
```
gcloud config set project <PROJECT_ID>

E.g.
gcloud config set project workshop-cmoulliard-redhat-com
```

* Enable Billing for the project

In order to create the resources and access to the Google APIs, we will link the project created to our billing id

```
gcloud alpha billing accounts projects link <PROJECT_ID> --account-id=<BILLING_ID>
E.g.
gcloud alpha billing accounts projects link workshop-cmoulliard-redhat-com --account-id=XXXXX-YYYYY-ZZZZZ
```

* Enable Services

Enable the following services to allow gcloud to create the VMS, networks, disks, ...

```
gcloud service-management enable cloudbilling.googleapis.com
gcloud service-management enable cloudapis.googleapis.com
gcloud service-management enable dns.googleapis.com
gcloud service-management enable compute-component.googleapis.com
```

* Change default location

Depending where you are based or running the VMS, it could be required that you would like to change the [region](https://cloud.google.com/compute/docs/regions-zones/regions-zones) and zone of the data center to be used

```
gcloud compute project-info add-metadata \
    --metadata google-compute-default-region=<REGION>,google-compute-default-zone=<ZONE>
    
E.g.    
gcloud compute project-info add-metadata \
    --metadata google-compute-default-region=europe-west1,google-compute-default-zone=europe-west1-b
```

* Add a Service Account

The next step will consist to create a service account and generate keys that the platform will use with your gcloud client to authorize you to perform some operations according to the role that 
you have.

To create a service account and the keys run the following commands:

```
gcloud iam service-accounts create <SA_ID> --display-name "my workshop service account"
where <SA_ID> is the name of the service account to be created "my-sa-123"
E.g.
gcloud iam service-accounts create my-workshop-sa --display-name "my workshop service account"


gcloud iam service-accounts keys create <KEY_FILE> --iam-account <SA_ID>@<PROJECT_ID>.iam.gserviceaccount.com    
E.g.
gcloud iam service-accounts keys create ~/key.json --iam-account my-sa-123@workshop-cmoulliard-redhat-com.iam.gserviceaccount.com   
```

* Give role owner

This step allows to give the role `owner` to the service account created and next to bind it using a IAM policy to the project to allow to manage using the gcloud client the creation of the resources

```
gcloud iam service-accounts add-iam-policy-binding <SA_ID>@<PROJECT_ID>.iam.gserviceaccount.com --role='roles/owner' --member='user:<EMAIL>'
E.g.
gcloud iam service-accounts add-iam-policy-binding my-workshop-sa@workshop-cmoulliard-redhat-com.iam.gserviceaccount.com --role='roles/owner' --member='user:cmoulliard@redhat.com'

gcloud projects add-iam-policy-binding <PROJECT_ID> --member='serviceAccount:<SA_ID>@<PROJECT_ID>.iam.gserviceaccount.com' --role='roles/owner' 
E.g.
gcloud projects add-iam-policy-binding workshop-cmoulliard-redhat-com --member='serviceAccount:my-workshop-sa@workshop-cmoulliard-redhat-com.iam.gserviceaccount.com' --role='roles/owner' 
```

* Create Cloud DNS Zone (optional)

This step is not required according to Marek Jelen. To be verified !

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

# Create VM, install OpenShift using OpenShifter

As the project, serviceAccount & Roles have been created we can now use the [OpenShifter](https://github.com/openshift-evangelists/openshifter) tool to create the VM (RHEL-7, CentOS), install OpenShift, Configure the users.
Remark: Start locally a Docker daemon or configure your docker client to access a Docker daemon running on a machine. When you use minishift locally, you can issue this command to configure it `minishift docker-env`

```
docker run -ti -v $(pwd):/root/data docker.io/osevg/openshifter:15 create <FILE_NAME_WITHOUT_EXTENSION>
where <FILE_NAME_WITHOUT_EXTENSION> corresponds to the file name of the yaml configuration to be used without `.extension`. IF your file is `cluster.yml`, then pass `cluster` as parameter
E.g.
docker run -ti -v $(pwd):/root/data docker.io/osevg/openshifter:15 create cluster
```

An example of the custer yaml config file to be used is included within this project [cluster.tmpl](cluster.tmpl)

This tool uses the GoogleApi to communicate with the GCP platform in order to create a VM, get an IP address, setup the network, create disks and apply firewall rules.
When the VM is ready, than ansible is used to provision the VM with OCP (E.g. 3.5, ...) and finally to create the users

The tool proposes other commands as :

* create = provision + install + setup
* provision =create the infra
* install = install OpenShift using Ansible on that infra
* setup = post installation steps, e.g. create users
* destroy

## Automated steps

### Create a GCP Project

```
./create_project.sh <PROJECT_ID> <EMAIL> <REGION> <ZONE>"
E.g. 
./create_project.sh workshop-jbcnconf cmoulliard@redhat.com"
```

### Delete a GCP Project

```
./delete_project.sh <PROJECT_ID>
E.g.
./delete_project.sh workshop-cmoulliard-redhat-com
```

### Create VM & install OpenShift

The `create-cluster.sh script will start a docker process running `openshifter` to create a VM (RHEL-7) on GCP and install OpenShift Container Platform.
The yaml config is defined within the `cluster01.yml` file

```
./create-cluster.sh cluster01
````

### Create several VMs

This bash script uses the `cluster.tmpl` template file to populate x VMs and will use as parameter your json keys file (created for the service Account), the project where the VMs should be created
, the number of occurences of VMs to be created and finally the SSH keys to be imported within the VM 

```
./create-clusters.sh <FILE_NAME_WITHOUT_EXTENSION> <INSTANCES> <GCP_JSON_FILE> <PROJECT_ID> <KEY_FILE>
E.g. 
./create-clusters.sh vm 10 demo-384301dab612.json stellar-spark-169312 openshift-key
```

# Tricks

## Delete a project

```
gcloud projects delete workshop-cmoulliard-redhat-com
```

## Alternative procedure to create a project and add emails

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

## To clean GCP resources

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