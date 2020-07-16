locals {
  collection_throughput = 40000
  db_throughput         = 1000
  cosmos_databases = [{
    name       = local.cosmos_db_name
    throughput = local.db_throughput
  }]

  cosmos_sql_collections = [{
    name               = "scoring-data"
    database_name      = local.cosmos_db_name
    partition_key_path = "/APPT_ID"
    throughput         = local.collection_throughput
    },
    {
      name               = "scheduling-data"
      database_name      = local.cosmos_db_name
      partition_key_path = "/id"
      throughput         = local.collection_throughput
  }]
}

module "sys_storage_account" {
  source              = "../../modules/providers/azure/storage-account"
  name                = local.sys_storage_name
  resource_group_name = azurerm_resource_group.app_rg.name
  container_names     = var.sys_storage_containers
}

module "app_storage_account" {
  source              = "../../modules/providers/azure/storage-account"
  name                = local.app_storage_name
  resource_group_name = azurerm_resource_group.app_rg.name
  container_names     = var.app_storage_containers
}

module "cosmosdb" {
  source                   = "../../modules/providers/azure/cosmosdb"
  account_name             = local.cosmos_account_name
  resource_group_name      = azurerm_resource_group.app_rg.name
  vnet_subnet_id           = module.network.subnet_ids[0]
  primary_replica_location = var.primary_replica_location
  databases                = local.cosmos_databases
  sql_collections          = local.cosmos_sql_collections
}

# //storage for ADF data prep
# module "storage_account" "adf_dataprep_storage" {
#   source = "../../modules/providers/azure/storage-account"

#   name                = local.storage_name
#   resource_group_name = azurerm_resource_group.app_rg.name
#   container_names     = var.storage_containers
# }

# //storage for ML ops workspace
# module "storage_account" "ml_workspace_storage" {
#   source = "../../modules/providers/azure/storage-account"

#   name                = local.storage_name
#   resource_group_name = azurerm_resource_group.app_rg.name
#   container_names     = var.storage_containers
# }
