locals {
  access_restriction_description = "blocking public traffic to function app"
  access_restriction_name        = "vnet_restriction"
  function_app_names             = keys(var.function_app_config)

  // Add app setting only if instrumentation key is set.
  insights_settings = var.instrumentation_key != "" ? {
    APPINSIGHTS_INSTRUMENTATIONKEY = var.instrumentation_key
  } : {}

  // Only Apply Docker App Settings if all values for URL, UserName and Password are given.
  docker_settings = length(compact([var.docker_registry_server_username, var.docker_registry_server_password, var.docker_registry_server_url])) == 3 ? {
    "DOCKER_REGISTRY_SERVER_URL" : format("https://%s", var.docker_registry_server_url)
    "DOCKER_REGISTRY_SERVER_USERNAME" : var.docker_registry_server_username
    "DOCKER_REGISTRY_SERVER_PASSWORD" : var.docker_registry_server_password
  } : {}

  app_settings = merge(
    local.insights_settings,
    local.docker_settings,
  )

  app_linux_fx_versions = [
    for config in values(var.function_app_config) :
    // Without specifyin a `linux_fx_version` the webapp created by the `azurerm_function_app` resource
    // will be a non-container webapp.
    //
    // The value of "DOCKER" is a stand-in value that can be used to force the webapp created to be
    // container compatible without explicitly specifying the image that the app should run.
    config.image == "" ? "DOCKER" : format("DOCKER|%s/%s", var.docker_registry_server_url, config.image)
  ]
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azurerm_storage_account" "main" {
  name                = var.storage_account_name
  resource_group_name = data.azurerm_resource_group.main.name
}

resource "azurerm_function_app" "main" {
  name                      = format("%s-%s", var.name, lower(local.function_app_names[count.index]))
  location                  = data.azurerm_resource_group.main.location
  resource_group_name       = var.resource_group_name
  app_service_plan_id       = var.service_plan_id
  storage_connection_string = data.azurerm_storage_account.main.primary_connection_string
  tags                      = var.resource_tags
  https_only                = true
  count                     = length(local.function_app_names)
  app_settings              = merge(tomap(local.app_settings), var.function_app_config[local.function_app_names[count.index]].app_settings)
  version                   = var.runtime_version

  site_config {
    linux_fx_version = local.app_linux_fx_versions[count.index]
    always_on        = var.is_always_on
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    # This stanza will prevent terraform from reverting changes to the application container settings.
    # These settings are how application teams deploy new containers to the app service and should not
    # be overridden by Terraform deployments.
    ignore_changes = [
      site_config[0].linux_fx_version
    ]
  }
}

resource "azurerm_template_deployment" "main" {
  name                = "access_restriction"
  count               = var.vnet_subnet_id != "" ? length(local.function_app_names) : 0
  resource_group_name = data.azurerm_resource_group.main.name

  parameters = {
    service_name                   = format("%s-%s", var.name, lower(local.function_app_names[count.index]))
    vnet_subnet_id                 = var.vnet_subnet_id
    access_restriction_name        = local.access_restriction_name
    access_restriction_description = local.access_restriction_description
  }

  deployment_mode = "Incremental"
  template_body   = file("${path.module}/azuredeploy.json")
  depends_on      = [azurerm_function_app.main]
}
