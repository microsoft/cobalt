module "provider" {
  source = "../../modules/providers/azure/provider"
}

module "backend_state" {
  source   = "github.com/Microsoft/bedrock/cluster/azure/backend-state"
  location = "${var.resource_group_location}"

  resource_tags = {
    environment = "${var.name}-single-region"
  }
}

resource "azurerm_resource_group" "cluster_rg" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"

  tags = {
    environment = "${var.name}-single-region"
  }
}

module "vnet" {
  source                  = "github.com/Microsoft/bedrock/cluster/azure/vnet"
  vnet_name               = "${var.vnet_name}"
  address_space           = "${var.address_space}"
  resource_group_name     = "${azurerm_resource_group.cluster_rg.name}"
  resource_group_location = "${azurerm_resource_group.cluster_rg.location}"
  subnet_names            = ["${var.cluster_name}-subnet"]
  subnet_prefixes         = ["${var.subnet_prefixes}"]

  tags = {
    environment = "${var.name}-single-region"
  }
}

module "service_plan" {
  source                  = "../../modules/providers/azure/service-plan"
  resource_group_name     = "${azurerm_resource_group.cluster_rg.name}"
  resource_group_location = "${azurerm_resource_group.cluster_rg.location}"
  service_plan_name       = "${var.service_plan_name}"

  resource_tags = {
    environment = "${var.name}-single-region"
  }
}

module "app_service" {
  source                  = "../../modules/providers/azure/app-service"
  resource_group_name     = "${azurerm_resource_group.cluster_rg.name}"
  resource_group_location = "${azurerm_resource_group.cluster_rg.location}"
  app_service_name        = "${var.app_service_name}"
  app_service_plan_id     = "${module.service_plan.app_service_plan_id}"

  resource_tags = {
    environment = "${var.name}-single-region"
  }
}

module "api_management" {
  source                  = "../../modules/providers/azure/api-mgmt"
  apimgmt_name            = "${var.apimgmt_name}"
  resource_group_name     = "${azurerm_resource_group.cluster_rg.name}"
  resource_group_location = "${azurerm_resource_group.cluster_rg.location}"

  resource_tags = {
    environment = "${var.name}-single-region"
  }
}

# module "app_gateway" {
#   source                  = "../../modules/providers/azure/app-gateway"
#   appgateway_name = "${var.appgateway_name}"
#   resource_group_name = "${var.resource_group_name}"
#   resource_group_location = "${var.resource_group_location}"
#   appgateway_ipconfig_name = "${var.appgateway_ipconfig_name}"
#   appgateway_frontend_port_name = "${var.appgateway_frontend_port_name}"
#   appgateway_frontend_ip_configuration_name = "${var.appgateway_frontend_ip_configuration_name}"
#   appgateway_frontend_public_ip_address_id = "${var.appgateway_frontend_public_ip_address_id}"
#   appgateway_listener_name = "${var.appgateway_listener_name}"
#   appgateway_request_routing_rule_name = "${var.appgateway_listener_name}"
#   appgateway_ipconfig_subnet_id = "${var.appgateway_ipconfig_subnet_id}"
#   appgateway_backend_http_setting_name = "${var.appgateway_backend_http_setting_name}"
#   appgateway_backend_address_pool_name = "${var.appgateway_backend_address_pool_name}"
#   resource_tags = {
#     environment = "${var.name}-single-region"
#   }
# }

module "traffic_manager_profile" {
  source                       = "github.com/Microsoft/bedrock/cluster/azure/tm-profile"
  traffic_manager_profile_name = "${var.traffic_manager_profile_name}"
  traffic_manager_dns_name     = "${var.traffic_manager_dns_name}"
  resource_group_name          = "${azurerm_resource_group.cluster_rg.name}"
  resource_group_location      = "${azurerm_resource_group.cluster_rg.location}"

  tags = {
    environment = "${var.name}-single-region"
  }
}

module "traffic_manager_endpoint" {
  source                              = "github.com/Microsoft/bedrock/cluster/azure/tm-endpoint-ip"
  resource_group_name                 = "${azurerm_resource_group.cluster_rg.name}"
  resource_location                   = "${azurerm_resource_group.cluster_rg.location}"
  traffic_manager_profile_name        = "${var.traffic_manager_profile_name}"
  traffic_manager_resource_group_name = "${azurerm_resource_group.cluster_rg.name}"
  public_ip_name                      = "${var.public_ip_name}"
  endpoint_name                       = "${var.endpoint_name}"
  ip_address_out_filename             = "${var.ip_address_out_filename}"

  tags = {
    environment = "${var.name}-single-region"
  }
}
