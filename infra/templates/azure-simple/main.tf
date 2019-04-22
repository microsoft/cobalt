module "provider" {
  source = "../../modules/providers/azure/provider"
}

resource "azurerm_resource_group" "cluster_rg" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
}

module "app_gateway" {
  source = "../../modules/providers/azure/app-gateway"
}

module "app_service" {
  source = "../../modules/providers/azure/service-plan"
}

module "service_plan" {
  source = "../../modules/providers/azure/service-plan"
}

module "apimanagement" {
  source = "../../modules/providers/azure/api-mgmt"
}

module "backend_state" {
  source   = "github.com/Microsoft/bedrock/cluster/azure/backend-state"
  location = "${var.resource_group_location}"
}

module "vnet" {
  source                  = "github.com/Microsoft/bedrock/cluster/azure/vnet"
  vnet_name               = "${var.vnet_name}"
  address_space           = "${var.address_space}"
  resource_group_name     = "${var.resource_group_name}"
  resource_group_location = "${var.resource_group_location}"
  subnet_names            = ["${var.cluster_name}-aks-subnet"]
  subnet_prefixes         = ["${var.subnet_prefixes}"]

  tags = {
    environment = "single-region"
  }
}

module "traffic_manager_profile" {
  source                       = "github.com/Microsoft/bedrock/cluster/azure/tm-profile"
  traffic_manager_profile_name = "${var.traffic_manager_profile_name}"
  traffic_manager_dns_name     = "${var.traffic_manager_dns_name}"
  resource_group_name          = "${var.resource_group_name}"
  resource_group_location      = "${var.resource_group_location}"
}

module "traffic_manager_endpoint" {
  source                              = "github.com/Microsoft/bedrock/cluster/azure/tm-endpoint-ip"
  resource_group_name                 = "${var.resource_group_name}"
  resource_location                   = "${var.resource_location}"
  traffic_manager_profile_name        = "${var.traffic_manager_profile_name}"
  traffic_manager_resource_group_name = "${var.traffic_manager_resource_group_name}"
  public_ip_name                      = "${var.public_ip_name}"
  endpoint_name                       = "${var.endpoint_name}"
  ip_address_out_filename             = "${var.ip_address_out_filename}"
}
