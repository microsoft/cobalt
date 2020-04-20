## app-service

A terraform module that provisions and scales enterprise-grade azure managed app service Linux-based containers. Meet rigorous performance, scalability, security and compliance requirements while using a fully managed platform to perform infrastructure maintenance.

More information for Azure App Services can be found [here](https://azure.microsoft.com/en-us/services/app-service/)

Cobalt provides the ability to provision a fleet of app service resources including the following characteristics:

- Provisions a fleet of app service linux containers through the `app_service_name` `map(string)`. The key resolves to the name of the app service resource while the value is the source image for the resource. We provision one app service resource(s) for each map entry.

- Supports continuous deployment through the `DOCKER_ENABLE_CI` setting(defaults to true). If this is set then a deployment webhook is generated.

- MSI keyvault integration.

- VNET access isolation.

- Canary deployments through an auto-provisioned staging slot.

## Usage

Key Vault certificate usage example:

```hcl
app_service_name = {
    cobalt-backend-api = "msftcse/az-service-single-region:release"
}

app_service_settings = {
  app_setting1 = "hw_setting_value",
  app_setting2 = "hw_setting_value"
}

module "service_plan" {
  source              = "../../modules/providers/azure/service-plan"
  resource_group_name = azurerm_resource_group.main.name
  service_plan_name   = "${azurerm_resource_group.main.name}-sp"
}

module "app_service" {
  source                           = "../../modules/providers/azure/app-service"
  app_service_name                 = var.app_service_name
  app_service_settings             = var.app_service_settings
  service_plan_name                = module.service_plan.service_plan_name
  service_plan_resource_group_name = azurerm_resource_group.main.name
  docker_registry_server_url       = "docker.io"
}
```

## Outputs

Once the deployments are completed successfully, the output for the current module will be in the format mentioned below:

```hcl
Outputs:

app_service_uri = [
    "appservice1.azurewebsites.net",
    "appservice2.azurewebsites.net"
]

app_service_ids = [
    "/resource/subscriptions/00000/resourceGroups/cobalt-az-simple-erik/providers/Microsoft.Web/sites/cobalt-backend-api-erik/appServices", ...
]

app_service_identity_tenant_id = [
    "0000000"
]

app_service_identity_object_ids = {
  "appservice1" = "00000"
}
```

## Attributes Reference

The following attributes are exported:

- `app_service_uri`: The URL of the app service created
- `app_service_ids`: The resource ids of the app service created
- `app_service_identity_tenant_id`: The Tenant ID for the Service Principal associated with the Managed Service Identity of this App Service
- `app_service_identity_object_ids`: The Principal IDs for the Service Principal associated with the Managed Service Identity for all App Services

## Argument Reference

Supported arguments for this module are available in [variables.tf](./variables.tf).
