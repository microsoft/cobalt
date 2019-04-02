#!/bin/bash
set -euo pipefail

. ../assert.sh continue_on_error #  load test functions with continue_on_error/stop_on_error

export TF_VAR_location=eastus
export TF_VAR_company=test

#Check if resource group exists
#Resource group does not exists at this point
assertRG core-usea-rg-test not

#Deploy all the test resources
terraform init ../../shared/
terraform apply -auto-approve ../../shared/

#Check if resource group was created
assertRG core-usea-rg-test

#Check if virtual network exists
assertResource core-usea-rg-test "Microsoft.Network/virtualNetworks" core-usea-vnet-test

#Check if subnet exists inside virtual network
assertSubnet core-usea-rg-test core-usea-vnet-test core-usea-subnet-test

#Destroy the test resources
terraform destroy -auto-approve ../../shared/
