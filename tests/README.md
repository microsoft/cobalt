# Dev Testing

## Requirements

- Azure CLI
- jq (apt-get install jq)

## Description

- assert.sh is the code used for the test functions needed for the test files.
- main.sh is the file that initiates the tests
- test.sh is an example file for testing the existence of resource groups in a subscription
- test2.sh is an example file for testing the existence resources in a resource group
 
## Asserts

The followng command chech for the existence of these resource (or resource gruop)
- assertRG \<resource_group_name\>
- assertResource \<resource_group_name\> \<resource_type\> \<resource_name\>

The 'not' at the end of the assert commands can be use to verify the non-existence of the resource (or resource group)
- assertRG \<resource_group_name\> not
- assertResource \<resource_group_name\> \<resource_type\> \<resource_name\> not

## Usage

1. Authenticate using your Azure Principal or an Azure account with privileges to deploy resource groups.

``` bash
az login
```

2. Execute the tests

``` bash
./main.sh
```