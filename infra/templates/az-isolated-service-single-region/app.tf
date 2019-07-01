// This file contains all of the resources that exist within the app dev subscription. Design documentation
// with more information on exactly what resources live here can be found at ./docs/design.md

// Note: unfortunately the alias cannot be configured by passing a variable through
// the module initialization!
provider "azurerm" {
  alias           = "app_dev"
  subscription_id = var.app_dev_subscription_id
}

resource "azurerm_resource_group" "app_rg" {
  name     = local.app_rg_name
  location = var.resource_group_location
  provider = azurerm.app_dev
}

// Query for the subnets within the VNET that lives in the admin subscription
data "external" "ase_subnets" {
  program = [
    "${path.module}/query_subnet_vnet_ids.sh",
    var.ase_subscription_id,
    var.ase_resource_group,
    var.ase_vnet_name
  ]
}

module "keyvault" {
  source              = "../../modules/providers/azure/keyvault"
  keyvault_name       = local.kv_name
  resource_group_name = azurerm_resource_group.app_rg.name
  subnet_id_whitelist = values(data.external.ase_subnets.result)
  providers = {
    "azurerm" = "azurerm.app_dev"
  }
}
