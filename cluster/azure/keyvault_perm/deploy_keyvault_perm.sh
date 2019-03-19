#!/bin/sh

# parse command-line arguments
while getopts :i:p: option 
do 
 case "${option}" in 
 i) SERVICE_PRINCIPAL_ID=${OPTARG};;
 p) SERVICE_PRINCIPAL_SECRET=${OPTARG};;
 esac
done 

echo "Adding service principal into KeyVault as a secret"
kubectl create secret generic kvcreds --from-literal clientid=$SERVICE_PRINCIPAL_ID --from-literal clientsecret=$SERVICE_PRINCIPAL_SECRET --type=azure/kv
if [ $? != 0 ]; then
    echo "Unable to add service principal secrets to kubectl secret"
    exit 1
fi