
# Resource deployment

## Requirements

- Azure Subscription
- Service Principal
- [Terraform](https://www.terraform.io/downloads.html)

## Resources

The following respources will be deployed
- Azure Resource Group
- Azure KeyVault 

## Deployment

1. Authenticate using your Azure Principal or an Azure account with privileges to deploy resource groups.

``` bash
$ az login
```

2. Execute the following commands:

``` bash
$ cd ./shared
$ terraform init
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
location="esatus"
company="myCompany"
```
