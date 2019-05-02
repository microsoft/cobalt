module "provider" {
  source = "../../modules/providers/azure/provider"
}

module "service_plan" {
  source                  = "../../modules/providers/azure/service-plan"
  resource_group_name     = "${var.resource_group_name}"
  service_plan_name       = "${var.service_plan_name}"
  resource_group_location = "${var.resource_group_location}"

  resource_tags = {
    environment = "${var.name}-single-region"
  }
}

module "vnet" {
  source                  = "github.com/Microsoft/bedrock/cluster/azure/vnet"
  vnet_name               = "${var.vnet_name}"
  address_space           = "${var.address_space}"
  resource_group_name     = "${module.service_plan.resource_group_name}"
  resource_group_location = "${var.resource_group_location}"
  subnet_names            = ["${var.subnet_names}"]
  subnet_prefixes         = ["${var.subnet_prefixes}"]

  tags = {
    environment = "${var.name}-single-region"
  }
}

module "app_service" {
  source                  = "../../modules/providers/azure/app-service"
  app_service_name        = "${var.app_service_name}"
  service_plan_name       = "${module.service_plan.service_plan_name}"
  service_plan_resource_group_name = "${module.service_plan.resource_group_name}"

  resource_tags = {
    environment = "${var.name}-single-region"
  }
}

# TODO: Pass the app service containers and site information from then envs.
#   app_settings = {
#     "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
#     "DOCKER_REGISTRY_SERVER_URL"          = "https://index.docker.io"
# }

# TODO: admin_password = "${data.azurerm_key_vault_secret.acrsecret.value}"

module "api_management" {
  source                  = "../../modules/providers/azure/api-mgmt"
  apimgmt_name            = "${var.apimgmt_name}"
  resource_group_name     = "${module.service_plan.resource_group_name}"
  resource_group_location = "${var.resource_group_location}"

  resource_tags = {
    environment = "${var.name}-single-region"
  }
}

# TODO: public IP?
resource "azurerm_public_ip" "pip" {
  name                = "${var.public_ip_name}-ip"
  location            = "${var.resource_group_location}"
  resource_group_name = "${module.service_plan.resource_group_name}"
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.public_ip_name}-dns"
}

module "app_gateway" {
  source                                    = "../../modules/providers/azure/app-gateway"
  appgateway_name                           = "${var.appgateway_name}"
  resource_group_name                       = "${module.service_plan.resource_group_name}"
  appgateway_ipconfig_name                  = "${var.appgateway_ipconfig_name}"
  appgateway_frontend_port_name             = "${var.appgateway_frontend_port_name}"
  appgateway_frontend_ip_configuration_name = "${var.appgateway_frontend_ip_configuration_name}"
  appgateway_listener_name                  = "${var.appgateway_listener_name}"
  appgateway_request_routing_rule_name      = "${var.appgateway_listener_name}"
  appgateway_backend_http_setting_name      = "${var.appgateway_backend_http_setting_name}"
  appgateway_backend_address_pool_name      = "${var.appgateway_backend_address_pool_name}"
  virtual_network_name                      = "${var.vnet_name}"
  subnet_name                               = "${var.subnet_names[0]}"

  # TODO: do we need a module or shall it create it?
  public_ip_name = "${azurerm_public_ip.pip.name}"

  resource_tags = {
    environment = "${var.name}-single-region"
  }
}

module "traffic_manager_profile" {
  source                       = "github.com/Microsoft/bedrock/cluster/azure/tm-profile"
  traffic_manager_profile_name = "${var.traffic_manager_profile_name}"
  traffic_manager_dns_name     = "${var.traffic_manager_dns_name}"
  resource_group_name          = "${module.service_plan.resource_group_name}"
  resource_group_location      = "${var.resource_group_location}"

  tags = {
    environment = "${var.name}-single-region"
  }
}

module "traffic_manager_endpoint" {
  source                              = "github.com/Microsoft/bedrock/cluster/azure/tm-endpoint-ip"
  resource_group_name                 = "${module.service_plan.resource_group_name}"
  resource_location                   = "${var.resource_group_location}"
  traffic_manager_profile_name        = "${var.traffic_manager_profile_name}"
  traffic_manager_resource_group_name = "${module.service_plan.resource_group_name}"
  public_ip_name                      = "${var.public_ip_name}"
  endpoint_name                       = "${var.endpoint_name}"
  ip_address_out_filename             = "${var.ip_address_out_filename}"

  tags = {
    environment = "${var.name}-single-region"
  }
}
