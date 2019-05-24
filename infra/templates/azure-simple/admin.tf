locals {
  tm_profile_name     = "${var.name}-tf"
  vnet_name           = "${var.name}-vnet"
  tm_endpoint_name    = "${var.resource_group_location}_${var.name}"
  tm_dns_name         = "${var.name}-dns"
  appgateway_name     = "${var.name}-gateway"
  public_pip_name     = "${var.name}-ip"
  kv_name             = "${var.name}-kv"
  resource_group_name = "${var.name}-${terraform.workspace}"
}

resource "azurerm_resource_group" "svcplan" {
  name     = "${local.resource_group_name}"
  location = "${var.resource_group_location}"
}

module "vnet" {
  source                   = "github.com/Microsoft/bedrock/cluster/azure/vnet"
  vnet_name                = "${local.vnet_name}"
  address_space            = "${var.address_space}"
  resource_group_name      = "${azurerm_resource_group.svcplan.name}"
  resource_group_location  = "${azurerm_resource_group.svcplan.location}"
  subnet_names             = ["${var.subnet_names}"]
  subnet_prefixes          = ["${var.subnet_prefixes}"]
  subnet_service_endpoints = "${var.subnet_service_endpoints}"
}

module "keyvault" {
  source              = "../../modules/providers/azure/keyvault"
  keyvault_name       = "${local.kv_name}"
  resource_group_name = "${azurerm_resource_group.svcplan.name}"
}

module "traffic_manager" {
  source                       = "../../modules/providers/azure/traffic-manager"
  resource_group_name          = "${azurerm_resource_group.svcplan.name}"
  traffic_manager_profile_name = "${local.tm_profile_name}"
  public_ip_name               = "${local.public_pip_name}"
  endpoint_name                = "${local.tm_endpoint_name}"
  traffic_manager_profile_name = "${local.tm_profile_name}"
  traffic_manager_dns_name     = "${local.tm_dns_name}"
}

module "keyvault_certificate" {
  source                   = "../../modules/providers/azure/keyvault-cert"
  keyvault_name            = "${module.keyvault.keyvault_name}"
  resource_group_name      = "${azurerm_resource_group.svcplan.name}"
  key_vault_cert_subject   = "${module.traffic_manager.public_pip_fqdn}"
  key_vault_cert_alt_names = ["${module.app_service.app_service_uri}"]
}

module "app_gateway" {
  source                     = "../../modules/providers/azure/app-gateway"
  appgateway_name            = "${local.appgateway_name}"
  resource_group_name        = "${azurerm_resource_group.svcplan.name}"
  virtual_network_name       = "${module.vnet.vnet_name}"
  appgateway_ssl_private_pfx = "${module.keyvault_certificate.private_pfx}"
  appgateway_ssl_public_cert = "${module.keyvault_certificate.public_cert}"
  public_pip_id              = "${module.traffic_manager.public_pip_id}"
  virtual_network_subnet_id  = "${module.vnet.vnet_subnet_ids[0]}"
  backendpool_fqdns          = "${module.app_service.app_service_uri}"
}
