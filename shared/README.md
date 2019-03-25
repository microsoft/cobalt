# App deployment

## Requirements

- Azure Subscription
- Service Principal
- [Terraform](https://www.terraform.io/downloads.html)

## Resources

The following respources will be deployed
- Azure Resource Group

## Deployment

``` bash
$ ./deploy.sh
```

To stop the command line from prompting questions use a .env file with the following environmental variables:

```
export SUBSCRIPTION_ID=41e239-xxxx-xxxx-xxxx-dff8b1089s65a
export APP_ID=faxxxx-1fec-xxxx-xxxx-9845414d7214
export APP_SECRET=fxxxxxxxxxqZ3too7ahZ3HRZWx3joEh7uA=
export TENANT_ID=7xxxx-86f1-41af-91ab-2d7cd011db47
export DEBUG=false
export DEPLOYMENT_NAME=mydeployment
export TF_VAR_app_name=cblt
export TF_VAR_org=cse
export TF_VAR_env=dev
export TF_VAR_location=eastus
```
