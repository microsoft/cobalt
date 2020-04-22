data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "azurerm_storage_account" "main" {
  # required
  name                     = lower(var.name)
  resource_group_name      = data.azurerm_resource_group.main.name
  location                 = data.azurerm_resource_group.main.location
  account_tier             = var.performance_tier
  account_replication_type = var.replication_type

  # optional
  account_kind              = var.kind
  enable_https_traffic_only = var.https
  account_encryption_source = var.encryption_source
  tags                      = var.resource_tags

  # enrolls storage account into azure 'managed identities' authentication
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_container" "main" {
  count                 = length(var.container_names)
  name                  = var.container_names[count.index]
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}
