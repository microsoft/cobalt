package test

import (
	"testing"

	"github.com/microsoft/terratest-abstraction/unit"
)

func appendCosmosDbTests(t *testing.T, description unit.ResourceDescription) {

	expectedcosmosdbsqlcontainercollection := asMap(t, `{
		"name"                : "scoring-data",
		"partition_key_path"  : "/APPT_ID",
		"throughput"          : 40000
	}`)
	description["module.cosmosdb.azurerm_cosmosdb_sql_container.cosmos_collections[0]"] = expectedcosmosdbsqlcontainercollection

	expectedschedulingcollection := asMap(t, `{
		"name"                : "scheduling-data",
		"partition_key_path"  : "/id",
		"throughput"          : 40000
	}`)
	description["module.cosmosdb.azurerm_cosmosdb_sql_container.cosmos_collections[1]"] = expectedschedulingcollection

	expectedcosmosdbaccount := asMap(t, `{
		"enable_automatic_failover"         : false,
		"enable_multiple_write_locations"   : false,
		"is_virtual_network_filter_enabled" : true,
		"kind"                              : "GlobalDocumentDB",
		"offer_type"                        : "Standard"
	}`)
	description["module.cosmosdb.azurerm_cosmosdb_account.main"] = expectedcosmosdbaccount

	expectedcosmosdbsqldatabase := asMap(t, `{
		"throughput"          : 1000
	}`)
	description["module.cosmosdb.azurerm_cosmosdb_sql_database.cosmos_dbs[0]"] = expectedcosmosdbsqldatabase

}
