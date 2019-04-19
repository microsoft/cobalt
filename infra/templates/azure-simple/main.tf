module "provider" {
  source = "../../modules/providers/azure"
}

resource "azurerm_resource_group" "cluster_rg" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
}

module "app_gateway" {
  source = "../../modules/providers/azure/app-gateway"
}

module "app_service" {
  source = ""
}

module "service_plan" {
  source = ""
}

module "apimanagement" {
  source = ""
}

module "backend_state" {
  source = "github.com/Microsoft/bedrock/cluster/azure/backend-state"
}

module "vnet" {
  source = "github.com/Microsoft/bedrock/cluster/azure/vnet"

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
  source = "github.com/Microsoft/bedrock/cluster/azure/tm-profile"
}

module "traffic_manager_endpoint" {
  source = "github.com/Microsoft/bedrock/cluster/azure/tm-endpoint-ip"
}
