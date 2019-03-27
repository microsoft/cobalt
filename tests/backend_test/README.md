# Backend Dev Testing

## Description

- main.sh is the parent file that contains all the tests
- assert.sh is the code used for the base functions needed to test the backend.

## Requirements:
Fill the values required below in test_backend.tfvars 

- Storage Account Name
- Storage Account Access Key
- Storage Account Container Name
- Key Name to store for Terraform State for Test Environment

#### Folder test1 contains test1.tf
1. Deploy Resource Group
2. Deploy KeyVault1
- Should deploy above resources

#### Folder test2 contains test2.tf
1. Deploy Resource Group
2. Deploy KeyVault1
3. Deploy KeyVault2 
- Should not change/deploy resource 1 and 2. Only deploy resource 3.

#### Folder test3 contains test3.tf
1. Deploy Resource Group
2. Deploy KeyVault1
3. Deploy KeyVault2
- Should not deploy any resource since above 3 resources are already deployed.

## Usage
``` bash
./main.sh
```