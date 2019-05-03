## Azure App Service

Build, deploy, and scale enterprise-grade web, mobile, and API apps running on any platform. Meet rigorous performance, scalability, security and compliance requirements while using a fully managed platform to perform infrastructure maintenance.

More information for Azure App Services can be found [here](https://azure.microsoft.com/en-us/services/app-service/)

Cobalt gives ability to specify following settings for App Service based on the requirements:
- name : The name of the App Services to be created. This is a map of app service name and the linux_fx_version/container image to be loaded for that app service. DOCKER|<user/image:tag>
- service_plan_resource_group_name : The Name of the Resource Group where the Service Plan exists.
- app_service_plan_id : The ID of the App Service Plan within which the App Service exists is populated automatically based on service plan.
- tags : A mapping of tags to assign to the resource.
- app_settings : A key-value pair of App Settings. Settings for private Container Registries
  - DOCKER_REGISTRY_SERVER_URL : The docker registry server URL for app service to be created
  - DOCKER_REGISTRY_SERVER_USERNAME : The docker registry server usernames for app services to be created
  - DOCKER_REGISTRY_SERVER_PASSWORD : The docker registry server passwords for app services to be created
- site_config : 
  - always_on : Should the app be loaded at all times? Defaults to false.
  - virtual_network_name : The name of the Virtual Network which this App Service should be attached to.

Please click the [link](https://www.terraform.io/docs/providers/azurerm/d/app_service.html) to get additional details on settings in Terraform for Azure App Service.

## Usage

### Module Definitions

The App Service is dependent on deployment of Service Plan. Make sure to deploy Service Plan before starting to deploy App Services.

- Service Plan Module : infra/modules/providers/azure/service-plan
- App Service Module : infra/modules/providers/azure/app-service

```
variable "resource_group_name" {
  value = "test-rg"
}

variable "service_plan_name" {
  value = "test-svcplan"
}

variable "app_service_name" {
  value = {
    appservice1="DOCKER|<user1/image1:tag1>"
    appservice2="DOCKER|<user2/image2:tag2>"
  }
}

module "service_plan" {
  source                  = "github.com/Microsoft/cobalt/infra/modules/providers/azure/service-plan"
  resource_group_name     = "${var.resource_group_name}"
  resource_group_location = "${var.resource_group_location}"
  service_plan_name       = "${var.service_plan_name}"
}

module "app_service" {
  source                           = "github.com/Microsoft/cobalt/infra/modules/providers/azure/app-service"
  service_plan_resource_group_name = "${var.resource_group_name}"
  service_plan_name                = "${var.service_plan_name}"
```

## Outputs

Once the deployments are completed successfully, the output for the current module will be in the format mentioned below:

```
Outputs:

app_service_uri = [
    appservice1.azurewebsites.net,
    appservice2.azurewebsites.net
]
```
