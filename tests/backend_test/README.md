# Backend Dev Testing

## Description

- [main.sh](../main.sh) is the parent file to execute, that contains all the tests.
- [assert.sh](../assert.sh) is the test framework used for the base functions required to test the backend.

## Requirements:
Fill the values required below in test_backend.tfvars using [this](../../shared/README.md###Configure-Terraform-to-Store-State-Data-in-Azure) link.

- Storage Account Name
- Storage Account Access Key
- Storage Account Container Name
- Key Name to store for Terraform State for Test Environment

#### Folder backend_create_multiple_resource_test1 contains backend_create_multiple_resource_test1.tf
1. Deploy Resource Group
2. Deploy KeyVault1
- Should deploy above resources

#### Folder backend_create_multiple_resource_test2 contains backend_create_multiple_resource_test2.tf
1. Deploy Resource Group
2. Deploy KeyVault1
3. Deploy KeyVault2 
- Should not change/deploy resource 1 and 2. Only deploy resource 3.

#### Folder backend_create_multiple_resource_test3 contains backend_create_multiple_resource_test3.tf
1. Deploy Resource Group
2. Deploy KeyVault1
3. Deploy KeyVault2
- Should not deploy any resource since above 3 resources are already deployed.

## Usage
``` bash
cd ../../tests
./main.sh
```