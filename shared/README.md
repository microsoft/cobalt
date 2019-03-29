
# Resource deployment

## Requirements

- Azure Subscription
- Service Principal
- [Terraform](https://www.terraform.io/downloads.html)

Fill the values required below in backend.tfvars to initialize Azure backend for Terraform 

- Storage Account Name
- Storage Account Access Key
- Storage Account Container Name
- Key Name to store for Terraform State for Test Environment


## Resources

The following resources will be deployed:
- Azure Resource Group
- Azure KeyVault 

## Deployment

1. Authenticate using your Azure Principal or an Azure account with privileges to deploy resource groups.

``` bash
$ az login
```

2. Execute the following commands to initialize Azure Backend and deploy resources:

``` bash
$ cd ./shared
$ terraform init -backend-config=./backend.tfvars 
$ terraform apply
```

To stop the command line from prompting questions use a .env file with the following environmental variables:

```
export TF_VAR_location=eastus
export TF_VAR_company=myCompany
```

After saving the file set environment using:

``` bash
. .env
```

Alternatively, use the cluster.tfvars file to set parameter values as shown below:

``` 
location="eastus"
company="myCompany"
```
