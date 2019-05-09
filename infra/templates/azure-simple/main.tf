locals {
  tm_ip_address_out_filename = "${var.name}_ip_address"
  tm_profile_name            = "${var.name}-tf"
  vnet_name                  = "${var.name}-vnet"
  service_plan_name          = "${var.name}-sp"
  tm_endpoint_name           = "${var.resource_group_location}_${var.name}"
  tm_dns_name                = "${var.name}-dns"
  appgateway_name            = "${var.name}-gateway"
  app_insights_name          = "${var.name}-ai"
}

module "provider" {
  source = "../../modules/providers/azure/provider"
}

module "service_plan" {
  source                  = "../../modules/providers/azure/service-plan"
  resource_group_name     = "${var.resource_group_name}"
  service_plan_name       = "${local.service_plan_name}"
  resource_group_location = "${var.resource_group_location}"
}

module "vnet" {
  source                   = "github.com/bedrock/cluster/azure/vnet"
  vnet_name                = "${local.vnet_name}"
  address_space            = "${var.address_space}"
  resource_group_name      = "${var.resource_group_name}"
  resource_group_location  = "${var.resource_group_location}"
  subnet_names             = ["${var.subnet_names}"]
  subnet_prefixes          = ["${var.subnet_prefixes}"]
  subnet_service_endpoints = "${var.subnet_service_endpoints}"
}

module "app_service" {
  source                           = "../../modules/providers/azure/app-service"
  app_service_name                 = "${var.app_service_name}"
  service_plan_name                = "${module.service_plan.service_plan_name}"
  service_plan_resource_group_name = "${var.resource_group_name}"
  app_insights_instrumentation_key = "${module.app_insight.app_insights_instrumentation_key}"
  docker_registry_server_url       = "${var.docker_registry_server_url}"
  docker_registry_server_username  = "${var.docker_registry_server_username}"
  docker_registry_server_password  = "${var.docker_registry_server_password}"
}

module "app_insight" {
  source                           = "../../modules/providers/azure/app-insights"
  service_plan_resource_group_name = "${module.service_plan.resource_group_name}"
  appinsights_name                 = "${local.app_insights_name}"
}

module "app_gateway" {
  source                                    = "../../modules/providers/azure/app-gateway"
  appgateway_name                           = "${local.appgateway_name}"
  resource_group_name                       = "${var.resource_group_name}"
  appgateway_frontend_port_name             = "${var.appgateway_frontend_port_name}"
  virtual_network_name                      = "${module.vnet.vnet_name}"
  backend_http_protocol                     = "${var.backend_http_protocol}"
  http_listener_protocol                    = "${var.http_listener_protocol}"
  subnet_name                               = "${var.subnet_names[0]}"
  backendpool_fqdns                         = "${module.app_service.app_service_uri}"
}

module "traffic_manager_profile" {
  source                       = "github.com/Microsoft/bedrock/cluster/azure/tm-profile"
  resource_group_name          = "${var.resource_group_name}"
  resource_group_location      = "${var.resource_group_location}"
  traffic_manager_profile_name = "${local.tm_profile_name}"
  traffic_manager_dns_name     = "${local.tm_dns_name}"
}

module "traffic_manager_endpoint" {
  source                              = "github.com/Microsoft/bedrock/cluster/azure/tm-endpoint-ip"
  resource_group_name                 = "${var.resource_group_name}"
  resource_location                   = "${var.resource_group_location}"
  traffic_manager_profile_name        = "${local.tm_profile_name}"
  traffic_manager_resource_group_name = "${var.resource_group_name}"
  public_ip_name                      = "${var.name}"
  endpoint_name                       = "${local.tm_endpoint_name}"
  ip_address_out_filename             = "${local.tm_ip_address_out_filename}"
}