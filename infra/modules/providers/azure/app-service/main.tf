locals {
  access_restriction_description = "blocking public traffic to app service"
  access_restriction_name        = "vnet_restriction"
}

data "azurerm_resource_group" "appsvc" {
  name = var.service_plan_resource_group_name
}

data "azurerm_app_service_plan" "appsvc" {
  name                = var.service_plan_name
  resource_group_name = data.azurerm_resource_group.appsvc.name
}

resource "azurerm_app_service" "appsvc" {
  name                = "${lower(element(keys(var.app_service_name), count.index))}-${lower(terraform.workspace)}"
  resource_group_name = data.azurerm_resource_group.appsvc.name
  location            = data.azurerm_resource_group.appsvc.location
  app_service_plan_id = data.azurerm_app_service_plan.appsvc.id
  tags                = var.resource_tags
  count               = length(keys(var.app_service_name))

  app_settings = {
    DOCKER_REGISTRY_SERVER_URL          = "https://${var.docker_registry_server_url}"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    DOCKER_REGISTRY_SERVER_USERNAME     = "${var.docker_registry_server_username}"
    DOCKER_REGISTRY_SERVER_PASSWORD     = "${var.docker_registry_server_password}"
    APPINSIGHTS_INSTRUMENTATIONKEY      = "${var.app_insights_instrumentation_key}"
    KEYVAULT_URI                        = "${var.vault_uri}"
    DOCKER_ENABLE_CI                    = "${var.docker_enable_ci}"
  }

  site_config {
    linux_fx_version     = "DOCKER|${var.docker_registry_server_url}/${element(values(var.app_service_name), count.index)}"
    always_on            = "${var.site_config_always_on}"
    virtual_network_name = "${var.vnet_name}"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_app_service_slot" "appsvc_staging_slot" {
  name                = "staging"
  app_service_name    = "${lower(element(keys(var.app_service_name), count.index))}-${lower(terraform.workspace)}"
  count               = length(keys(var.app_service_name))
  location            = data.azurerm_resource_group.appsvc.location
  resource_group_name = data.azurerm_resource_group.appsvc.name
  app_service_plan_id = data.azurerm_app_service_plan.appsvc.id
  depends_on          = [azurerm_app_service.appsvc]
}

resource "azurerm_template_deployment" "access_restriction" {
  name                = "access_restriction"
  count               = var.vnet_name == "" ? 0 : length(keys(var.app_service_name))
  resource_group_name = data.azurerm_resource_group.appsvc.name

  parameters = {
    service_name                   = "${lower(element(keys(var.app_service_name), count.index))}-${lower(terraform.workspace)}"
    vnet_subnet_id                 = var.vnet_subnet_id
    access_restriction_name        = local.access_restriction_name
    access_restriction_description = local.access_restriction_description
  }

  deployment_mode = "Incremental"
  template_body   = file("${path.module}/azuredeploy.json")
  depends_on      = [azurerm_app_service.appsvc]
}

