# Azure Functions

This module simplifies provisioning [Azure Functions](https://azure.microsoft.com/en-us/services/functions/), and if needed deploy the azure function app from docker container.


## What are Azure Functions?

From the official [Documentation](https://docs.microsoft.com/en-us/azure/azure-functions/functions-overview):

> Azure Functions is a solution for easily running small pieces of code, or "functions," in the cloud. You can write just the code you need for the problem at hand, without worrying about a whole application or the infrastructure to run it. Functions is a great solution for processing data, integrating systems, working with the internet-of-things (IoT), and building simple APIs and microservices.


## Current Features

 * Provisions a set of azure function apps.
 * Supports [managed identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview) integration.
 * Supports azure resource [tags](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-using-tags).
 * Supports [Application Insights](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview) integration.
 * Supports [Service Plan](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans) integration.
 * Function [App Setting](https://docs.microsoft.com/en-us/azure/azure-functions/functions-app-settings) configuration.
 * Supports [Container Functions](https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-function-linux-custom-image?tabs=nodejs)
 * Supports [Secure App Settings](https://docs.microsoft.com/en-us/azure/app-service/app-service-key-vault-references)

## Module Usage

There are a lot of different [function-app-settings](https://docs.microsoft.com/en-us/azure/azure-functions/functions-app-settings) necessary for function apps. That are neccessary to be set by the user of the module.

The following app-settings are automatically applied if variables information is provided.


__Application Insights__

```
  var.app_insights_instrumentation_key --> APPINSIGHTS_INSTRUMENTATIONKEY
```

__Private Registry Information__ _(All DOCKER variables have to exist)_
```
  var.docker_registry_server_url      --> DOCKER_REGISTRY_SERVER_URL
  var.docker_registry_server_username --> DOCKER_REGISTRY_SERVER_USERNAME
  var.docker_registry_server_password --> DOCKER_REGISTRY_SERVER_PASSWORD
```

### Basic Usage Example

```hcl-terraform

module "function_app" {
  source                              = "../../modules/providers/azure/function-app"
  fn_name_prefix                      = local.func_app_name_prefix
  resource_group_name                 = azurerm_resource_group.app_rg.name
  service_plan_id                     = module.service_plan.id
  storage_account_resource_group_name = module.sys_storage_account.resource_group_name
  storage_account_name                = module.sys_storage_account.name
  vnet_subnet_id                      = module.network.subnet_ids[0]
  fn_app_settings                     = local.func_app_settings
  fn_app_config                       = var.fn_app_config
}
```


### Prerequisites
This module assumes that there are a [resource group](https://docs.microsoft.com/en-us/azure/azure-resource-manager/manage-resource-groups-portal#create-resource-groups), an [app service plan](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans), and a [storage account resource](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview)

You will need to provide the following information for the dependencies:
 - Resource group name.
 - App service plan id.
 - Storage account name.


#### Configuring `function_app_config`

This is a map where the key is the `function_app_name` and the definition for the function app:

- For Docker based deployment, the object has one field:
image: which refers to the docker image name to deploy.
- For running from a package, it should contains the fields:
  - zip: contains an http reference to the package.

> This will enable your function app to run from a package by adding a WEBSITE_RUN_FROM_PACKAGE setting to your function app settings.

- hash: contains a hash of the zip file for downloads integrity check.


### Manually deploying Private ACR Images

If no image is deployed due to the usage of a Private ACR configuration then the `image` should be left blank and images can be deployed post terraform provisioning has occured by using the Azure CLI or some other process. The below example uses the Azure CLI and docker.

```bash
RESOURCE_GROUP="<resource_group_name>"
REGISTRY_SERVER="<registry_server_name>"
FUNCTION_APP="<function_app_name>"

# Update the function app Container
az functionapp config container show --resource-group $RESOURCE_GROUP --name $FUNCTION_APP

# Login to the Registry Server
az acr login -n $REGISTRY_SERVER

# Pull a Sample Function and Push it to the Private Registry
docker push $REGISTRY_SERVER.azurecr.io/sample-function:latest

# Update the function app Container
az functionapp config container set --docker-custom-image-name $REGISTRY_SERVER.azurecr.io/sample-function:latest --resource-group $RESOURCE_GROUP --name $FUNCTION_APP
```


### Input Variables

Please refer to [variables.tf](variables.tf).

### Output Variables

Please refer to [output.tf](output.tf).
