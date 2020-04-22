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
  var.instrumentation_key --> APPINSIGHTS_INSTRUMENTATIONKEY
```

__Private Registry Information__ _(All DOCKER variables have to exist)_
```
  var.docker_registry_server_url_app_setting      --> DOCKER_REGISTRY_SERVER_URL
  var.docker_registry_server_username_app_setting --> DOCKER_REGISTRY_SERVER_USERNAME
  var.docker_registry_server_password_app_setting --> DOCKER_REGISTRY_SERVER_PASSWORD
```

### Basic Usage Example

```h
locals {
  unique           = "${random_id.sample.hex}"
  rg               = "iac-sample"
  storage_name     = "${local.unique}sa"
  plan_name        = "${local.unique}-ap"
  functionapp_name = "${local.unique}-fa"
}

resource "azurerm_resource_group" "sample" {
  name     = local.rg
  location = "eastus"
}

resource "random_id" "sample" {
  keepers = {
    resource_group = azurerm_resource_group.sample.name
  }

  byte_length = 4
}

module "storage_account" {
  source              = "../../storage-account"

  name                = replace(local.storage_name, "-", "")
  resource_group_name = azurerm_resource_group.sample.name

  container_names     = []
}

module "service_plan" {
  source                = "../../service-plan"

  service_plan_name     = local.plan_name
  resource_group_name   = azurerm_resource_group.sample.name

  service_plan_tier     = "PremiumV2"
  service_plan_size     = "P1v2"
}

module "function_app" {
  source                  = "../"

  name                    = local.unique
  resource_group_name     = azurerm_resource_group.sample.name

  storage_account_name    = module.storage_account.name
  service_plan_id         = module.service_plan.app_service_plan_id

  function_app_config = {
    javafunc : {
      app_settings = {
        "FUNCTIONS_EXTENSION_VERSION"         = "~2",
        "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = false
        "FUNCTIONS_WORKER_RUNTIME"            = "java"
      }
      image = ""
    },
    dotnetfunc : {
      app_settings = {
        "FUNCTIONS_EXTENSION_VERSION"         = "~2",
        "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = false
        "FUNCTIONS_WORKER_RUNTIME"            = "dotnet"
      }
      image = ""
    }
  }
}
```

### Advanced Usage Example

```h
locals {
  unique           = "${random_id.sample.hex}"
  rg               = "iac-testing"
  storage_name     = "iac${local.unique}sa"
  insights_name    = "iac${local.unique}-in"
  vault_name       = "iac${local.unique}-kv"
  plan_name        = "iac${local.unique}-ap"
  registry_name    = "iac${local.unique}cr"
  functionapp_name = "${local.unique}-fa"
  principal_name   = "iac${local.unique}"

  secret_map       = {
    for secret in module.keyvault_container_secrets.keyvault_secret_attributes :
      secret.name => secret.id
  }
}

resource "azurerm_resource_group" "sample" {
  name     = local.rg
  location = "eastus"
}

resource "random_id" "sample" {
  keepers = {
    resource_group = azurerm_resource_group.sample.name
  }

  byte_length = 4
}

module "storage_account" {
  source              = "../../storage-account"

  name                = replace(local.storage_name, "-", "")
  resource_group_name = azurerm_resource_group.sample.name

  container_names     = []
}

module "service_plan" {
  source                = "../../service-plan"

  service_plan_name     = local.principal_name
  resource_group_name   = azurerm_resource_group.sample.name

  service_plan_tier     = "PremiumV2"
  service_plan_size     = "P1v2"
}

module "keyvault" {
  source              = "../../keyvault"

  keyvault_name       = "${local.vault_name}"
  resource_group_name = azurerm_resource_group.sample.name
}

module "keyvault_function_app_access_policy" {
  source     = "../../keyvault-policy"

  vault_id   = module.keyvault.keyvault_id
  tenant_id  = module.function_app.identity_tenant_id
  object_ids = module.function_app.identity_object_ids
  key_permissions = [ "get", "list"]
  secret_permissions = [ "get", "list"]
  certificate_permissions = [ "get", "list"]
}

module "container_registry" {
  source                           = "../../container-registry"

  container_registry_name          = local.registry_name
  resource_group_name              = azurerm_resource_group.sample.name

  container_registry_sku           = "Standard"
  container_registry_admin_enabled = false
}

module "service_principal" {
  source          = "../../service-principal"

  display_name    = local.principal_name

  create_for_rbac = true
  role_name       = "Reader"
  role_scopes     = [module.container_registry.container_registry_id]
}

module "keyvault_container_secrets" {
  source               = "../../keyvault-secret"

  keyvault_id          = module.keyvault.keyvault_id
  secrets              = {
    registryusername = module.service_principal.service_principal_application_id
    registrypassword = module.service_principal.service_principal_password
  }
}

module "function_app" {
  source                  = "../"

  name                    = "iac${local.unique}"
  resource_group_name     = local.unique

  storage_account_name    = module.storage_account.name
  service_plan_id         = module.service_plan.app_service_plan_id

  docker_registry_server_url_app_setting = module.container_registry.container_registry_login_server
  docker_registry_server_username_app_setting = format("@Microsoft.KeyVault(SecretUri=%s)", local.secret_map.registryusername)
  docker_registry_server_password_app_setting = format("@Microsoft.KeyVault(SecretUri=%s)", local.secret_map.registrypassword)

  function_app_config = {
    function1 : {
      app_settings = {
        "FUNCTIONS_EXTENSION_VERSION"         = "~2",
        "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = false
        "FUNCTIONS_WORKER_RUNTIME"            = "java"
      }
      image = ""
    }
  }
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

  - **`app_settings`:** The function app settings config map.
  - **`image`:** The docker image name.

### Manually deploying Private ACR Images

If no image is deployed due to the usage of a Private ACR configuration then the `image` should be left blank and images can be deployed post terraform provisioning has occured by using the Azure CLI or some other process.

```
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


## Resources

| Resource | Description |
|--------|-------------|
| azurerm_function_app | The actual azure function app resources being created and deployed. |

### Input Variables

Please refer to [variables.tf](./variables.tf).

### Output Variables

Please refer to [output.tf](./output.tf).
