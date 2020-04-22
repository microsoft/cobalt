# Module Azure Cosmos DB

Azure Cosmos DB is Microsoft's globally distributed, multi-model database service. With a click of a button, Cosmos DB enables you to elastically and independently scale throughput and storage across any number of Azure regions worldwide. You can elastically scale throughput and storage, and take advantage of fast, single-digit-millisecond data access using your favorite API including SQL, MongoDB, Cassandra, Tables, or Gremlin. Cosmos DB provides comprehensive service level agreements (SLAs) for throughput, latency, availability, and consistency guarantees, something no other database service offers.

More information for Azure Cosmos DB can be found [here](https://azure.microsoft.com/en-us/services/cosmos-db/)

Please click the [link](https://www.terraform.io/docs/providers/azurerm/r/cosmosdb_account.html) to get additional details on settings in Terraform for Azure Cosmos DB.

## Usage

### Module Definitions

- Cosmos DB Module        : infra/modules/providers/azure/cosmosdb

```
module "cosmosdb" {
  source                      = "github.com/Microsoft/cobalt/infra/modules/providers/azure/cosmosdb"
  cosmosdb_name               = "test-name-cosmosdb"
  resource_group_name         = ${azurerm_resource_group.cosmosdb.name} 
  cosmosdb_kind               = "test-kind-cosmosdb"
  cosmosdb_automatic_failover = true | false
  consistency_level           = "BoundedStaleness" | "Eventual" | "Session" | "Strong" | "ConsistentPrefix"
  primary_replica_location    = "test-azure-region"
  databases                   = [
    {
      name       = "office"
      throughput = 400
    }
  ]
  sql_collections             = [
    {
      name               = "employees"
      database_name      = "office"
      partition_key_path = "/location_id"
      throughput         = 400
    }
  ]
}
```
## Argument Reference

Supported arguments for this module are available in [variables.tf](./variables.tf).

## Outputs

Once the deployments are completed successfully, the output for the current module will be in the format mentioned below:

``` json
output "properties" {
  description = "Properties of the deployed CosmosDB account."
  type        = object({
    cosmosdb = object({
      id                     = string
      endpoint               = string
      primary_master_key     = string
      connection_strings     = string
    })
  })
}

output "resource_group_name" {
  description = "The name of the CosmosDB account."
  type        = string
}

output "account_name" {
  description = "Properties of the deployed cluster"
  type        = string
}
```

