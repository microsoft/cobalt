# Module Azure Cosmos DB

Azure Cosmos DB is Microsoft's globally distributed, multi-model database service. With a click of a button, Cosmos DB enables you to elastically and independently scale throughput and storage across any number of Azure regions worldwide. You can elastically scale throughput and storage, and take advantage of fast, single-digit-millisecond data access using your favorite API including SQL, MongoDB, Cassandra, Tables, or Gremlin. Cosmos DB provides comprehensive service level agreements (SLAs) for throughput, latency, availability, and consistency guarantees, something no other database service offers.

More information for Azure Cosmos DB can be found [here](https://azure.microsoft.com/en-us/services/cosmos-db/)

A terraform module in Cobalt to provide Cosmos DB with the following characteristics:

- Ability to specify resource group name in which the Cosmos DB is deployed.
- Ability to specify resource group location in which the Cosmos DB is deployed.
- Also gives ability to specify the following for Azure Cosmos DB based on the requirements:
  - name : (Required) Specifies the name of the CosmosDB Account. Changing this forces a new resource to be created.
  - resource_group_name : (Required) The name of the resource group in which the CosmosDB Account is created. Changing this forces a new resource to be created.
  - location : (Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created.
  - offer_type : (Required) Specifies the Offer Type to use for this CosmosDB Account - currently this can only be set to Standard.
  - kind : (Optional) Specifies the Kind of CosmosDB to create; possible values are GlobalDocumentDB and MongoDB. Defaults to GlobalDocumentDB. Changing this forces a new resource to be created. 
  - enable_automatic_failover : (Optional) Enable automatic fail over for this Cosmos DB account.   
  - consistency_policy : (Required) Specifies a consistency_policy resource, used to define the consistency policy for this CosmosDB account.
    - consistency_level : (Required) The Consistency Level to use for this CosmosDB Account - can be either BoundedStaleness, Eventual, Session, Strong or ConsistentPrefix.
  - geo_location : (Required) Specifies a geo_location resource, used to define where data should be replicated with the failover_priority 0 specifying the primary location.
    - location : (Required) The name of the Azure region to host replicated data.
    - failover_priority : (Required) The failover priority of the region. A failover priority of 0 indicates a write region. The maximum value for a failover priority = (total number of regions - 1). Failover priority values must be unique for each of the regions in which the database account exists. Changing this causes the location to be re-provisioned and cannot be changed for the location with failover priority 0.

Please click the [link](https://www.terraform.io/docs/providers/azurerm/r/cosmosdb_account.html) to get additional details on settings in Terraform for Azure Cosmos DB.

## Usage

### Module Definitions

- Cosmos DB Module        : infra/modules/providers/azure/cosmosdb

```
module "cosmosdb" {
  source                      = "github.com/Microsoft/cobalt/infra/modules/providers/azure/cosmosdb"
  cosmosdb_name               = "test-cosmosdb-name"
  resource_group_name         = ${azurerm_resource_group.cosmosdb.name} 
  cosmosdb_kind               = "test-cosmosdb-kind"
  cosmosdb_automatic_failover = true | false
  consistency_level           = "BoundedStaleness" | "Eventual" | "Session" | "Strong" | "ConsistentPrefix"
  primary_replica_location    = "test-azure-region"
}
```

## Outputs

Once the deployments are completed successfully, the output for the current module will be in the format mentioned below:

```
Outputs:

cosmosdb_endpoint = <cosmosdburl>
cosmosdb_primary_master_key = <cosmosdbprimaryaccesskey>
cosmosdb_connection_strings = [<cosmosdbconnectionstrings>]
```
