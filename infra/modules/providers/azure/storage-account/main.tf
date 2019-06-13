resource "azurerm_storage_account" "sa" {
  resource_group_name       = "${var.resource_group_name}"
  location                  = "${var.resource_group_location}"
  name                      = "${lower(var.account_name)}"
  account_tier              = "${var.performance_tier}"
  account_replication_type  = "${var.replication_type}"

  # optional
  account_kind              = "${var.kind}"
  enable_https_traffic_only = "${var.https}"
  account_encryption_source = "${var.encryption_source}"

  # enrolls storage account into azure 'managed identities'
  identity = {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_container" "sa" {
  name                  = "${var.storage_container_name}"
  resource_group_name   = "${var.resource_group_name}"
  storage_account_name  = "${azurerm_storage_account.sa.name}"
  container_access_type = "private"
}
