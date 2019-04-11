#!/bin/bash
set -euo pipefail

#Cleanup
#terraform init -backend-config="access_key=$TF_VAR_access_key" -backend-config="resource_group_name=28da1541feed-remote-state-rg" -backend-config="storage_account_name=$TF_VAR_storage_account_name" -backend-config="container_name=$TF_VAR_container_name" -backend-config="key=cobalt-test-terraform.tfstate" 
terraform init -backend-config=./backend_test/test_backend.tfvars ./backend_test/backend_create_multiple_resource_test3
terraform destroy -auto-approve ./backend_test/backend_create_multiple_resource_test3

#Check if resource group exists
#Resource group does not exists
assertRG core-usea-rg-test not

#Create Resource group and Keyvault 1
terraform init -backend-config=./backend_test/test_backend.tfvars ./backend_test/backend_create_multiple_resource_test1
terraform apply -auto-approve ./backend_test/backend_create_multiple_resource_test1

#Check if resource group exists
assertRG core-usea-rg-test
assertResource core-usea-rg-test "Microsoft.KeyVault/vaults" core-usea-kv1-test

#Key Vault 2 does not exists
assertResource core-usea-rg-test "Microsoft.KeyVault/vaults" core-usea-kv2-test not

terraform init -backend-config=./backend_test/test_backend.tfvars ./backend_test/backend_create_multiple_resource_test2
#Deploy Key Vault 2 only
terraform apply -auto-approve ./backend_test/backend_create_multiple_resource_test2

assertRG core-usea-rg-test
assertResource core-usea-rg-test "Microsoft.KeyVault/vaults" core-usea-kv1-test
assertResource core-usea-rg-test "Microsoft.KeyVault/vaults" core-usea-kv2-test
before=`az resource list -g core-usea-rg-test --resource-type Microsoft.KeyVault/vaults --query '[].name' --o tsv | wc -l`

#Deploy Nothing since resources are already deployed
terraform init -backend-config=./backend_test/test_backend.tfvars ./backend_test/backend_create_multiple_resource_test3
terraform apply -auto-approve ./backend_test/backend_create_multiple_resource_test3
after=`az resource list -g core-usea-rg-test --resource-type Microsoft.KeyVault/vaults --query '[].name' --o tsv | wc -l`
assertRG core-usea-rg-test
assertResource core-usea-rg-test "Microsoft.KeyVault/vaults" core-usea-kv1-test
assertResource core-usea-rg-test "Microsoft.KeyVault/vaults" core-usea-kv2-test

if [ $before -eq $after ]
then
    printf "\e[0;32mTest Passed: Number of resources in resource group are the same before and after the current test \n"
else
    printf "\e[0;31mTest Failed... \n"
fi

terraform destroy -auto-approve ./backend_test/backend_create_multiple_resource_test3
