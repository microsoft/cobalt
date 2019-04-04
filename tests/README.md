# Dev Testing

## Requirements

- Azure CLI

## Description

- assert.sh is the code used for the test functions needed for the test files.
- main.sh is the file that initiates the tests
  - sampleTest1.sh is an example file for testing the existence of resource groups in a subscription
  - sampleTest2.sh is an example file for testing the existence resources in a resource group
 
## Asserts

The following command check for the existence of these resources (or resource group):
- assertRG \<resource_group_name\>
- assertResource \<resource_group_name\> \<resource_type\> \<resource_name\>
- assertSubnet \<resource-group-name\> \<vnet-name\> \<subnet-name\>

The 'not' at the end of the assert commands can be use to verify the non-existence of the resource (or resource group)
- assertRG \<resource_group_name\> not
- assertResource \<resource_group_name\> \<resource_type\> \<resource_name\> not
- assertSubnet \<resource-group-name\> \<vnet-name\> \<subnet-name\> not

To add additional asserts to your code edit the assert.sh file included and follow the parent implementation.

## Usage

1. Authenticate using your Azure Principal or an Azure account with privileges to deploy resources.

``` bash
az login
```

2. Execute the tests

``` bash
./main.sh
```