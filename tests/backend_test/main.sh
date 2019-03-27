#!/bin/bash
set -euo pipefail

. ../assert.sh continue_on_error #  load test functions with continue_on_error/stop_on_error

#Cleanup
terraform init -backend-config=./test_backend.tfvars test3
terraform destroy -auto-approve test3

#Check if resource group exists
#Resource group does not exists #Fail
printf "\e[0;31mIf below test 'Failed' then test passed \n"
assertRG rg-test-cblt-msft

#Create Resource group and Keyvault 1
terraform init -backend-config=./test_backend.tfvars test1
terraform apply -auto-approve test1

#Check if resource group exists
assertRG rg-test-cblt-msft
assertResource rg-test-cblt-msft "Microsoft.KeyVault/vaults" kv1-test-cblt-msft

#Key Vault 2 does not exists #Fail
printf "\e[0;31mIf below test 'Failed' then test passed \n"
assertResource rg-test-cblt-msft "Microsoft.KeyVault/vaults" kv2-test-cblt-msft

terraform init -backend-config=./test_backend.tfvars test2
terraform apply -auto-approve test2

assertRG rg-test-cblt-msft
assertResource rg-test-cblt-msft "Microsoft.KeyVault/vaults" kv1-test-cblt-msft
assertResource rg-test-cblt-msft "Microsoft.KeyVault/vaults" kv2-test-cblt-msft
before=`az resource list -g rg-test-cblt-msft --resource-type "Microsoft.KeyVault/vaults"|jq .[].name| wc -l`


terraform init -backend-config=./test_backend.tfvars test3
terraform apply -auto-approve test3
after=`az resource list -g rg-test-cblt-msft --resource-type "Microsoft.KeyVault/vaults"|jq .[].name| wc -l`
assertRG rg-test-cblt-msft
assertResource rg-test-cblt-msft "Microsoft.KeyVault/vaults" kv1-test-cblt-msft
assertResource rg-test-cblt-msft "Microsoft.KeyVault/vaults" kv2-test-cblt-msft

if [ $before -eq $after ]
then
    printf "\e[0;32mTest Passed: Number of resources in resource group are the same before and after the current test \n"
else
    printf "\e[0;31mTest Failed... \n"
fi

terraform destroy -auto-approve test3
