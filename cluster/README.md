# Cluster deployment

## Requirements

- Azure Subscription
- Service Principal
- [Terraform](https://www.terraform.io/downloads.html)

## Resources

The following respources will be deployed
- Azure Resource Group
- Azure KeyVault 

## Deployment

``` bash
$ cd cluster
$ sh ./deploy.sh
```

To stop the command line from prompting questions use a .env file with the following environmental variables:

```
export SUBSCRIPTION_ID=41e239-xxxx-xxxx-xxxx-dff8b1089s65a
export APP_ID=faxxxx-1fec-xxxx-xxxx-9845414d7214
export APP_SECRET=fdwqwe131stuvqZ3too7ahZ3HRZWx3joEh7uA=
export TENANT_ID=7xxxx-86f1-41af-91ab-2d7cd011db47
export DEBUG=false
export TF_VAR_resource_group_location=eastus
export TF_VAR_env=prod
export TF_VAR_org=myorg
```
