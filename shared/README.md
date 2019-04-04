
# Resource deployment

## Requirements

- Azure Subscription
- Service Principal
- [Terraform](https://www.terraform.io/downloads.html)

## Resources

The following resources will be deployed
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

Alternative use the variable.tf files in the directories and add the default key on the file as shown on the example below:

``` json
variable "location" {
    type = "string"
    description = "The name of the target location"
    default = "eastus"
}
variable "env" {
    type = "string",
    description = "The short name of the target env (i.e. dev, staging, or prod)"
    default = "dev"
}
variable "org" {
    type = "string",
    description = "The short name of the organization"
    default = "cse"
}
variable "app_name" {
    type = "string",
    description = "The short name of the application"
    default = "cblt"
}

```
Alternatively, use the cluster.tfvars file to set parameter values as shown below:

``` 
location="esatus"
company="myCompany"
```
