# Dev Testing

## Description

- assert.sh is the code used for the test functions needed for the test files.
- main.sh is the file that initiates the tests
- test.sh is an example file for testing the existence of resource groups in a subscription
- test2.sh is an example file for testing the existence resources in a resource group
 
## Asserts

- assertRG \<resource_group_name\>
- assertResource \<resource_group_name\> \<resource_type\> \<resource_name\>

## Usage

1. Authenticate using your Azure Principal or an Azure account with privileges to deploy resource groups.

``` bash
az login
```

2. Execute the tests

``` bash
./main.sh
```