module "azure-provider" {
  source = "../provider"
}

data "azurerm_resource_group" "kv" {
  name = var.resource_group_name
}

data "azurerm_client_config" "current" {
}

# Note: Any access policies needed for the keyvault should be created using
# the `keyvault-policy` module. More information on why can be found here:
#   https://www.terraform.io/docs/providers/azurerm/r/key_vault.html#access_policy
resource "azurerm_key_vault" "keyvault" {
  name                = var.keyvault_name
  location            = data.azurerm_resource_group.kv.location
  resource_group_name = data.azurerm_resource_group.kv.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = var.keyvault_sku

  # This block configures VNET integration if a subnet whitelist is specified
  dynamic "network_acls" {
    # this block allows the loop to run 1 or 0 times based on if the resource ip whitelist or subnet id whitelist is provided.
    for_each = length(concat(var.resource_ip_whitelist, var.subnet_id_whitelist)) == 0 ? [] : [""]
    content {
      bypass                     = "None"
      default_action             = "Deny"
      virtual_network_subnet_ids = var.subnet_id_whitelist
      ip_rules                   = var.resource_ip_whitelist
    }
  }

  tags = var.resource_tags
}

module "deployment_service_principal_keyvault_access_policies" {
  source                  = "../keyvault-policy"
  vault_id                = azurerm_key_vault.keyvault.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_ids              = [data.azurerm_client_config.current.object_id]
  key_permissions         = var.keyvault_key_permissions
  secret_permissions      = var.keyvault_secret_permissions
  certificate_permissions = var.keyvault_certificate_permissions
}
