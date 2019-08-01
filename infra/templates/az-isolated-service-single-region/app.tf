// This file contains all of the resources that exist within the app dev subscription. Design documentation
// with more information on exactly what resources live here can be found at ./docs/design.md

// Note: unfortunately the alias cannot be configured by passing a variable through
// the module initialization!
provider "azurerm" {
  alias           = "app_dev"
  subscription_id = local.app_sub_id
}

resource "azurerm_resource_group" "app_rg" {
  name     = local.app_rg_name
  location = var.resource_group_location
  provider = azurerm.app_dev
}

resource "azurerm_management_lock" "app_rg_lock" {
  name       = format("%s-delete-lock", local.app_rg_name)
  scope      = azurerm_resource_group.app_rg.id
  lock_level = "CanNotDelete"
  provider   = azurerm.app_dev

  lifecycle {
    prevent_destroy = true
  }
}

// Query for the subnets within the VNET that lives in the admin subscription
data "external" "ase_subnets" {
  program = [
    "${path.module}/query_subnet_vnet_ids.sh",
    local.ase_sub_id,
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

module "container_registry" {
  source                  = "../../modules/providers/azure/container-registry"
  container_registry_name = local.acr_name
  resource_group_name     = azurerm_resource_group.app_rg.name
  // Note: this is requird until App Services and ACR work over MSI. See the design document for more details.
  container_registry_admin_enabled = true
  // Note: only premium ACRs allow configuration of network access restrictions
  container_registry_sku = "Premium"
  providers = {
    "azurerm" = "azurerm.app_dev"
  }
}

# Configures the default rule to be "Deny All Traffic"
resource "null_resource" "acr_default_deny_network_rule" {
  triggers = {
    acr_id = module.container_registry.container_registry_id
  }

  provisioner "local-exec" {
    command = "az acr update --name ${module.container_registry.container_registry_name} --default-action Deny"
  }
}

# Configures access from the subnets that should have access
resource "null_resource" "acr_acr_subnet_access_rule" {
  count      = length(values(data.external.ase_subnets.result))
  depends_on = ["null_resource.acr_default_deny_network_rule"]

  triggers = {
    acr_id  = module.container_registry.container_registry_id
    subnets = join(",", values(data.external.ase_subnets.result))
  }

  provisioner "local-exec" {
    command = "az acr network-rule add --name ${module.container_registry.container_registry_name} --subnet ${values(data.external.ase_subnets.result)[count.index]}"
  }
}