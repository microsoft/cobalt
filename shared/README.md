# Infrastructure deployment

## Requirements

- Azure Subscription User (with deployment rights)
- [Terraform](https://www.terraform.io/downloads.html)

## Resources

The following respources will be deployed
- Azure Resource Group

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

## Environmental Variables 

To stop the command line from prompting questions use a .env file with the following environmental variables:

```
export TF_VAR_app_name=cblt
export TF_VAR_org=cse
export TF_VAR_env=dev
export TF_VAR_location=eastus
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
    defailt = "dev"
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