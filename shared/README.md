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

- terraform init
- terraform apply

To stop the command line from prompting questions use a .env file with the following environmental variables:

```
export DEBUG=false
export TF_VAR_resource_group_location=eastus
export TF_VAR_env=prod
export TF_VAR_org=myorg
```
