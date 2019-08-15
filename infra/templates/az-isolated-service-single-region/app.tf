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
  source                = "../../modules/providers/azure/keyvault"
  keyvault_name         = local.kv_name
  resource_group_name   = azurerm_resource_group.app_rg.name
  subnet_id_whitelist   = values(data.external.ase_subnets.result)
  resource_ip_whitelist = var.resource_ip_whitelist
  providers = {
    "azurerm" = "azurerm.app_dev"
  }
}

module "container_registry" {
  source                  = "../../modules/providers/azure/container-registry"
  container_registry_name = local.acr_name
  resource_group_name     = azurerm_resource_group.app_rg.name
  // Note: this is requird until App Services and ACR work over MSI. See the design document for more details.
  container_registry_admin_enabled = false
  // Note: only premium ACRs allow configuration of network access restrictions
  container_registry_sku = "Premium"
  subnet_id_whitelist    = values(data.external.ase_subnets.result)
  resource_ip_whitelist  = var.resource_ip_whitelist
  providers = {
    "azurerm" = "azurerm.app_dev"
  }
}

module "app_service_principal_contributor" {
  source          = "../../modules/providers/azure/service-principal"
  create_for_rbac = true
  display_name    = local.svc_principal_name
  role_name       = "Contributor"
  role_scope      = "${module.container_registry.container_registry_id},${module.keyvault.keyvault_id},${module.service_plan.app_service_plan_id}"
}

module "app_service_principal_secrets" {
  source      = "../../modules/providers/azure/keyvault-secret"
  keyvault_id = module.keyvault.keyvault_id
  secrets     = local.app_secrets
}

module "acr_service_principal_acrpull" {
  source          = "../../modules/providers/azure/service-principal"
  create_for_rbac = true
  display_name    = local.acr_svc_principal_name
  role_name       = "acrpull"
  role_scope      = "${module.container_registry.container_registry_id}"
}

module "acr_service_principal_secrets" {
  source      = "../../modules/providers/azure/keyvault-secret"
  keyvault_id = module.keyvault.keyvault_id
  secrets     = local.acr_secrets
}

module "acr_service_principal_password" {
  source      = "../../modules/providers/azure/keyvault-secret"
  keyvault_id = module.keyvault.keyvault_id
  secrets     = local.acr_password
}
