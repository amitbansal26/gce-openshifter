#!/bin/bash

for i in {1..10}; do
  VM_NAME="vm-$i"
  gcloud compute disks delete $VM_NAME-master-docker --quiet
  gcloud compute disks delete $VM_NAME-master-root --quiet
  gcloud compute addresses delete $VM_NAME-master --quiet
  gcloud compute firewall-rules delete $VM_NAME-internal --quiet
  gcloud compute firewall-rules delete $VM_NAME-master --quiet
  gcloud compute firewall-rules delete $VM_NAME-all --quiet
  gcloud compute firewall-rules delete $VM_NAME-infra --quiet
  gcloud compute networks delete $VM_NAME --quiet
done