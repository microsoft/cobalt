package tests

import (
	"os"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

// CosmosDBAccountName the name of the Database account in CosmosDB
var cosmosDBAccountName = os.Getenv("COSMOSDB_ACCOUNT_NAME")

// PrimaryReplicaLocation the Azure region for the primary replica
var primaryReplicaLocation = os.Getenv("PRIMARY_REPLICA_LOCATION")

// ResourceGroupName the name of the resource group
var resourceGroupName = os.Getenv("RESOURCE_GROUP_NAME")

// CosmosDBOptions terraform options used for cosmos integration testing
var CosmosDBOptions = &terraform.Options{
	TerraformDir: "../../",
	Upgrade:      true,
	Vars: map[string]interface{}{
		"name":                     cosmosDBAccountName,
		"resource_group_name":      resourceGroupName,
		"primary_replica_location": primaryReplicaLocation,
	},
}
