# Azure Cache for Redis

The `redis-cache` module simplifies provisioning **[Azure Cache for Redis](https://docs.microsoft.com/en-us/azure/azure-cache-for-redis/cache-overview)** for our Terraform based Cobalt Infrastructure Templates (CITs). It grants CITs the ability to configure **Azure Cache for Redis** for all available pricing tiers offered by Microsoft Azure.

## What is Azure Redis for Cache?

From the official [Documentation](hhttps://docs.microsoft.com/en-us/azure/azure-cache-for-redis/cache-overview):

> "Azure Cache for Redis is based on the popular software Redis. It is typically used as a cache to improve the performance and scalability of systems that rely heavily on backend data-stores. Performance is improved by temporarily copying frequently accessed data to fast storage located close to the application. With Azure Cache for Redis, this fast storage is located in-memory with Azure Cache for Redis instead of being loaded from disk by a database."

## Current Features

An instance of the `redis-cache` module deploys the _**Azure Redis for Cache**_ service in order to provide templates with the following:

- Ability to deploy Azure Redis for Cache using SSL certificates and https within a single resource group.

- Ability to deploy Azure Redis for Cache premium and standard tier with a single set of configurable `memory_features` properties for managing in-memory server performance.

- Ability to deploy Azure Redis for Cache premium with or without clustering.

> **Excluded features:** VNET, Subnet, Keyvault, MI, High-availability zone customization (still in preview), Multi-count module (module that deploys multiple redis instances), Shared storage account, Append Only File (AOF) persistence, and notify keyspace events.

### Module Usage

```json
locals {
  ws_name     = replace(trimspace(lower(terraform.workspace)), "_", "-")
  app_rg_Name = "${local.ws_name}-cblt-redis-rg"
  region      = "eastus"
}

resource "azurerm_resource_group" "main" {
  name     = local.app_rg_name
  location = local.region
}

module "redis_cache" {
  # Required inputs
  source              = "../../modules/providers/azure/redis-cache"
  name                = "cblt-deployment"
  resource_group_name = azurerm_resource_group.main.name

  # Basic, Standard and Premimum Tier Inputs (optional)
  capacity                   = 0
  sku_name                   = "Basic"
  ssl_tls_version            = "1.2"

  # Standard & Premium Tier Inputs for In Memory Management (optional)
  memory_features = {
    maxmemory_reserved              = 50
    maxmemory_delta                 = 50
    maxmemory_policy                = "volatile-lru"
    maxfragmentationmemory_reserved = 50
  }

  # Distinct Premium Tier Inputs (optional)
  premium_tier_config = {
    server_patch_day  = "Friday"
    server_patch_hour = 7
    cache_shard_count = 0
  }
}
```

> NOTE: This example is configured for the basic tier and is overly verbose for demonstration purposes. All optional inputs above display sensible default values that don't need to be provided here if relying on defaults.

### Resources

| Resource | Terraform Link | Description |
|---|---|---|
| `azurerm_redis_cache` | [redis cache](https://www.terraform.io/docs/providers/azurerm/r/redis_cache.html) | This resource will be declared within the module. |

### Input Variables

Please refer to [variables.tf](./variables.tf).

### Output Variables

Please refer to [output.tf](./output.tf).

### Automated Tests

#### Run Integration Tests

This module's integration tests validate a provisioned Terraform workspace. Follow these steps to setup your local workspace and apply the execution plan in Azure. 

```hcl
cp .env.testing.template .env
## NOTE: You'll need to fill out the values for CACHE_NAME and RESOURCE_GROUP_NAME in .env
export $(cat .env | xargs)

terraform init
terraform workspace new redis-ws
terraform plan -var name=$CACHE_NAME -var resource_group_name=$RESOURCE_GROUP_NAME
terraform apply

go test -v $(go list ./... | grep "integration")
```

### Configuring Inputs

Visit the [azure cache for redis best practices](https://docs.microsoft.com/en-us/azure/azure-cache-for-redis/cache-best-practices) page for more guidance on configuring our `redis-cache` module.

#### Configuring `capacity`

Please visit _**Azure Cache for Redis's**_ [Cache Pricing Details](https://azure.microsoft.com/en-us/pricing/details/cache/) page for more information on choosing the right cache for your scenarios.

#### Configuring `memory_features`

Please visit _**Redis's**_ [Eviction Policies](https://redis.io/topics/lru-cache#eviction-policies) for more information on the trade-offs between different maximum memory policy threshold configurations in [Azure Cache for Redis Setting](https://docs.microsoft.com/en-us/azure/azure-cache-for-redis/cache-configure#settings).

#### Configuring `premium_tier_config`

Please visit _**Azure Cache for Redis's**_ [Premium Tier Intro](https://docs.microsoft.com/en-us/azure/azure-cache-for-redis/cache-premium-tier-intro)  for more information on premium configurations.

#### Configuring `cache_shard_count` of `premium_tier_config`

Please visit _**Azure Cache for Redis's**_ [Premium Clustering](https://docs.microsoft.com/en-us/azure/azure-cache-for-redis/cache-how-to-premium-clustering) page for more information on choosing whether or not clustering is right for you.

### Observability Support

For support on extending this module for observability, please visit [Redis Cache Metrics with Azure Monitoring](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/metrics-supported#microsoftcacheredis).
