data "azurerm_client_config" "current" {}

locals {
  access_restriction_description = "blocking public traffic to app service"
  access_restriction_name        = "vnet_restriction"
  acr_webhook_name               = "cdhook"
  app_names                      = keys(var.app_service_config)
  app_configs                    = values(var.app_service_config)
}

data "azurerm_resource_group" "appsvc" {
  name = var.service_plan_resource_group_name
}

data "azurerm_app_service_plan" "appsvc" {
  name                = var.service_plan_name
  resource_group_name = data.azurerm_resource_group.appsvc.name
}

resource "azurerm_app_service" "appsvc" {
  name                = var.app_service_name
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
    DOCKER_ENABLE_CI                    = var.docker_enable_ci
  }

  site_config {
    linux_fx_version     = format("DOCKER|%s/%s", var.docker_registry_server_url, local.app_configs[count.index].image)
    always_on            = var.site_config_always_on
    virtual_network_name = var.vnet_name
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "null_resource" "acr_webhook_creation" {
  count      = var.docker_enable_ci == true && var.uses_acr ? length(local.app_names) : 0
  depends_on = [azurerm_app_service.appsvc]

  triggers = {
    images_to_deploy = "${join(",", [for config in local.app_configs : config.image])}"
    acr_name         = var.azure_container_registry_name
  }

  provisioner "local-exec" {
    command = "az acr webhook create --registry $ACRNAME --name $APPNAME$WRKSPACE$WEBHOOKNAME --actions push --uri $(az webapp deployment container show-cd-url -n $APPNAME_URL-$WRKSPACE_URL -g $APPSVCNAME --query CI_CD_URL -o tsv)"

    environment = {
      ACRNAME      = var.azure_container_registry_name
      APPNAME      = replace(lower(local.app_names[count.index]), "-", "")
      WRKSPACE     = replace(lower(terraform.workspace), "-", "")
      APPNAME_URL  = lower(local.app_names[count.index])
      WRKSPACE_URL = lower(terraform.workspace)
      WEBHOOKNAME  = local.acr_webhook_name
      APPSVCNAME   = data.azurerm_resource_group.appsvc.name
    }

  }
}

resource "azurerm_app_service_slot" "appsvc_staging_slot" {
  name                = "staging"
  app_service_name    = var.app_service_name
  count               = length(local.app_names)
  location            = data.azurerm_resource_group.appsvc.location
  resource_group_name = data.azurerm_resource_group.appsvc.name
  app_service_plan_id = data.azurerm_app_service_plan.appsvc.id
  depends_on          = [azurerm_app_service.appsvc]
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
    service_name                   = var.app_service_name
    vnet_subnet_id                 = var.vnet_subnet_id
    access_restriction_name        = local.access_restriction_name
    access_restriction_description = local.access_restriction_description
  }

  deployment_mode = "Incremental"
  template_body   = file("${path.module}/azuredeploy.json")
  depends_on      = [data.azurerm_app_service.all]
}
