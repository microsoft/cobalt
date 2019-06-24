resource "azurerm_storage_account" "sa" {
  resource_group_name      = var.resource_group_name
  location                 = var.resource_group_location
  name                     = lower(var.account_name)
  account_tier             = var.performance_tier
  account_replication_type = var.replication_type

  # optional
  account_kind              = var.kind
  enable_https_traffic_only = var.https
  account_encryption_source = var.encryption_source

  # enrolls storage account into azure 'managed identities' authentication
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_container" "sa" {
  count                 = length(var.storage_container_names)
  name                  = "${var.storage_container_names[count.index]}"
  resource_group_name   = var.resource_group_name
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

module "service-principal" {
  source       = "../service-principal"
  object_id    = var.existing_sp_object_id
  role_name    = var.storage_role_definition_name
  role_scope   = azurerm_storage_account.sa.id
}