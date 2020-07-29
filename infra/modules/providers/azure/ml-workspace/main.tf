
module "azure-provider" {
  source = "../provider"
}

data "azurerm_resource_group" "ml_resource_group" {
  name = var.resource_group_name
}

resource "azurerm_machine_learning_workspace" "mlworkspace" {
  name                    = var.name
  location                = data.azurerm_resource_group.ml_resource_group.location
  resource_group_name     = var.resource_group_name
  application_insights_id = var.application_insights_id
  key_vault_id            = var.key_vault_id
  storage_account_id      = var.storage_account_id
  sku_name                = var.sku_name
  identity {
    type = "SystemAssigned" //This is the only supported type at this time
  }
}