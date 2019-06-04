data "azurerm_resource_group" "cosmosdb" {
  name = "${var.service_plan_resource_group_name}"
}

resource "azurerm_cosmosdb_account" "cosmosdb" {
  name                = "${var.cosmosdb_name}"
  location            = "${data.azurerm_resource_group.cosmosdb.location}"
  resource_group_name = "${data.azurerm_resource_group.cosmosdb.name}"
  offer_type          = "Standard"
  kind                = "${var.cosmosdb_kind}"

  enable_automatic_failover = "${var.cosmosdb_automatic_failover}"

  consistency_policy {
    consistency_level = "${var.consistency_level}"
  }

  geo_location {
    location          = "${var.primary_replica_location}"
    failover_priority = 0
  }
}
