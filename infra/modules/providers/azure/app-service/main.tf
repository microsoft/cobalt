locals {
  access_restriction_description = "blocking public traffic to app service"
  access_restriction_name        = "vnet_restriction"
}

data "azurerm_resource_group" "appsvc" {
  name = "${var.service_plan_resource_group_name}"
}

data "azurerm_app_service_plan" "appsvc" {
  name                = "${var.service_plan_name}"
  resource_group_name = "${data.azurerm_resource_group.appsvc.name}"
}

resource "azurerm_app_service" "appsvc" {
  name                = "${element(keys(var.app_service_name), count.index)}"
  resource_group_name = "${data.azurerm_resource_group.appsvc.name}"
  location            = "${data.azurerm_resource_group.appsvc.location}"
  app_service_plan_id = "${data.azurerm_app_service_plan.appsvc.id}"
  tags                = "${var.resource_tags}"
  count               = "${length(keys(var.app_service_name))}"

  app_settings {
    DOCKER_REGISTRY_SERVER_URL      = "${var.docker_registry_server_url}"
    DOCKER_REGISTRY_SERVER_USERNAME = "${var.docker_registry_server_username}"
    DOCKER_REGISTRY_SERVER_PASSWORD = "${var.docker_registry_server_password}"
    APPINSIGHTS_INSTRUMENTATIONKEY  = "${var.app_insights_instrumentation_key}"
  }

  site_config {
    linux_fx_version     = "${element(values(var.app_service_name), count.index)}"
    always_on            = "${var.site_config_always_on}"
    virtual_network_name = "${var.vnet_name}"
  }
}

resource "azurerm_app_service_slot" "appsvc_staging_slot" {
  name                = "${element(keys(var.app_service_name), count.index)}-staging"
  app_service_name    = "${element(keys(var.app_service_name), count.index)}"
  count               = "${length(keys(var.app_service_name))}"
  location            = "${data.azurerm_resource_group.appsvc.location}"
  resource_group_name = "${data.azurerm_resource_group.appsvc.name}"
  app_service_plan_id = "${data.azurerm_app_service_plan.appsvc.id}"
  depends_on          = ["azurerm_app_service.appsvc"]
}

resource "azurerm_template_deployment" "access_restriction" {
  name                = "access_restriction"
  count               = "${length(keys(var.app_service_name))}"
  resource_group_name = "${data.azurerm_resource_group.appsvc.name}"

  parameters = {
    service_name                   = "${element(keys(var.app_service_name), count.index)}"
    vnet_subnet_id                 = "${var.vnet_subnet_id}"
    access_restriction_name        = "${local.access_restriction_name}"
    access_restriction_description = "${local.access_restriction_description}"
  }

  deployment_mode = "Incremental"
  template_body   = "${file("${path.module}/azuredeploy.json")}"
  depends_on      = ["azurerm_app_service.appsvc"]
}
