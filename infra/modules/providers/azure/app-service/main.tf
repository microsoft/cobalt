data "azurerm_client_config" "current" {}

locals {
  access_restriction_description = "blocking public traffic to app service"
  access_restriction_name        = "vnet_restriction"
  acr_webhook_name               = "cdhook"
  app_names                      = keys(var.app_service_config)
  app_configs                    = values(var.app_service_config)

  app_linux_fx_versions = [
    for config in values(var.app_service_config) :
    // Without specifyin a `linux_fx_version` the webapp created by the `azurerm_app_service` resource
    // will be a non-container webapp.
    //
    // The value of "DOCKER" is a stand-in value that can be used to force the webapp created to be
    // container compatible without explicitly specifying the image that the app should run.
    config.image == "" ? "DOCKER" : format("DOCKER|%s/%s", var.docker_registry_server_url, config.image)
  ]
}

data "azurerm_resource_group" "appsvc" {
  name = var.service_plan_resource_group_name
}

data "azurerm_app_service_plan" "appsvc" {
  name                = var.service_plan_name
  resource_group_name = data.azurerm_resource_group.appsvc.name
}

resource "azurerm_app_service" "appsvc" {
  name                = format("%s-%s", var.app_service_name_prefix, lower(local.app_names[count.index]))
  resource_group_name = data.azurerm_resource_group.appsvc.name
  location            = data.azurerm_resource_group.appsvc.location
  app_service_plan_id = data.azurerm_app_service_plan.appsvc.id
  tags                = var.resource_tags
  count               = length(local.app_names)

  app_settings = {
    DOCKER_REGISTRY_SERVER_URL          = format("https://%s", var.docker_registry_server_url)
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    DOCKER_REGISTRY_SERVER_USERNAME     = var.docker_registry_server_username
    DOCKER_REGISTRY_SERVER_PASSWORD     = var.docker_registry_server_password
    APPINSIGHTS_INSTRUMENTATIONKEY      = var.app_insights_instrumentation_key
    KEYVAULT_URI                        = var.vault_uri
  }

  site_config {
    linux_fx_version     = local.app_linux_fx_versions[count.index]
    always_on            = var.site_config_always_on
    virtual_network_name = var.vnet_name
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    # This stanza will prevent terraform from reverting changes to the application container settings.
    # These settings are how application teams deploy new containers to the app service and should not
    # be overridden by Terraform deployments.
    ignore_changes = [
      "site_config[0].linux_fx_version"
    ]
  }
}

resource "azurerm_app_service_slot" "appsvc_staging_slot" {
  name                = "staging"
  app_service_name    = format("%s-%s", var.app_service_name_prefix, lower(local.app_names[count.index]))
  count               = length(local.app_names)
  location            = data.azurerm_resource_group.appsvc.location
  resource_group_name = data.azurerm_resource_group.appsvc.name
  app_service_plan_id = data.azurerm_app_service_plan.appsvc.id
  depends_on          = [azurerm_app_service.appsvc]

  app_settings = {
    DOCKER_REGISTRY_SERVER_URL          = format("https://%s", var.docker_registry_server_url)
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    DOCKER_REGISTRY_SERVER_USERNAME     = var.docker_registry_server_username
    DOCKER_REGISTRY_SERVER_PASSWORD     = var.docker_registry_server_password
    APPINSIGHTS_INSTRUMENTATIONKEY      = var.app_insights_instrumentation_key
    KEYVAULT_URI                        = var.vault_uri
  }

  site_config {
    linux_fx_version     = local.app_linux_fx_versions[count.index]
    always_on            = var.site_config_always_on
    virtual_network_name = var.vnet_name
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    # This stanza will prevent terraform from reverting changes to the application container settings.
    # These settings are how application teams deploy new containers to the app service and should not
    # be overridden by Terraform deployments.
    ignore_changes = [
      "site_config[0].linux_fx_version"
    ]
  }
}

data "azurerm_app_service" "all" {
  count               = length(azurerm_app_service.appsvc)
  name                = azurerm_app_service.appsvc[count.index].name
  resource_group_name = data.azurerm_resource_group.appsvc.name
}

resource "azurerm_template_deployment" "access_restriction" {
  name                = "access_restriction"
  count               = var.uses_vnet ? length(local.app_names) : 0
  resource_group_name = data.azurerm_resource_group.appsvc.name

  parameters = {
    service_name                   = format("%s-%s", var.app_service_name_prefix, lower(local.app_names[count.index]))
    vnet_subnet_id                 = var.vnet_subnet_id
    access_restriction_name        = local.access_restriction_name
    access_restriction_description = local.access_restriction_description
  }

  deployment_mode = "Incremental"
  template_body   = file("${path.module}/azuredeploy.json")
  depends_on      = [data.azurerm_app_service.all]
}
