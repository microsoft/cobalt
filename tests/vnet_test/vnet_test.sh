#!/bin/bash
set -euo pipefail

export TF_VAR_vnet_name=core-usea-vnet-test
export TF_VAR_resource_group_name=core-usea-rg-test
export TF_VAR_resource_group_location=eastus

# export TF_VAR_location=eastus
# export TF_VAR_company=test

#Check if resource group exists
#Resource group does not exists at this point
assertRG core-usea-rg-test not

#Deploy all the test resources
terraform init ../infra/modules/providers/azure/vnet
terraform apply -auto-approve ../infra/modules/providers/azure/vnet

#Check if resource group was created
assertRG core-usea-rg-test

#Check if virtual network exists
assertResource core-usea-rg-test "Microsoft.Network/virtualNetworks" core-usea-vnet-test

#Check if subneta exists inside virtual network
assertSubnet core-usea-rg-test core-usea-vnet-test subnet1
assertSubnet core-usea-rg-test core-usea-vnet-test subnet2

#Destroy the test resources
terraform destroy -auto-approve ../infra/modules/providers/azure/vnet
