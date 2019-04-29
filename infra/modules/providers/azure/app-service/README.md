## Azure App Service

Build, deploy, and scale enterprise-grade web, mobile, and API apps running on any platform. Meet rigorous performance, scalability, security and compliance requirements while using a fully managed platform to perform infrastructure maintenance.

More information for Azure App Services can be found [here](https://azure.microsoft.com/en-us/services/app-service/)

Cobalt gives ability to specify following settings for App Service based on the requirements:
- name : The name of the App Services to be created.
- service_plan_resource_group_name : The Name of the Resource Group where the Service Plan exists.
- app_service_plan_id : The ID of the App Service Plan within which the App Service exists is populated automatically based on service plan.
- tags : A mapping of tags to assign to the resource.
- app_settings : A key-value pair of App Settings. Settings for private Container Registries
  - DOCKER_REGISTRY_SERVER_URL : The docker registry server URL for app service to be created
  - DOCKER_REGISTRY_SERVER_USERNAME : The docker registry server usernames for app services to be created
  - DOCKER_REGISTRY_SERVER_PASSWORD : The docker registry server passwords for app services to be created
- site_config : 
  - linux_fx_version : Linux App Frameworks and versions for the App Services created. Possible options are a Docker container (DOCKER|<user/image:tag>), a base-64 encoded Docker Compose file (COMPOSE|${base64encode(file("compose.yml"))}) or a base-64 encoded Kubernetes Manifest (KUBE|${base64encode(file("kubernetes.yml"))}).
  - always_on : Should the app be loaded at all times? Defaults to false.

Please click the [link](https://www.terraform.io/docs/providers/azurerm/d/app_service.html) to get additional details on settings in Terraform for Azure App Service.

## Usage

### Module Definitions

- Service Plan Module : infra/modules/providers/azure/service-plan
- App Service Module : infra/modules/providers/azure/app-service

```
module "service_plan" {
  resource_group_name                 = "test-rg"
  resource_group_location             = "eastus"
  service_plan_name                   = "test-svcplan"
}

module "app_service" {
  service_plan_resource_group_name    = "test-rg"
  service_plan_name                   = "test-svcplan"
  app_service_name                    = ["app_service_name1", "app_service_name2"]
}
```
