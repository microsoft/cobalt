# Elastic Search Service (ESS)

This module simplifies provisioning [ELK Services](https://www.elastic.co/what-is/elk-stack) within a [Elastic Search Service](https://www.elastic.co/elasticsearch/service) (ESS) cluster using Terraform.


## Supported Scenarios

- Provisioning [Elasticsearch](https://www.elastic.co/products/elastic-stack) clusters on ESS.

***Note**: Support will be for `CREATE` and `DELETE` scenarios until there exists a native Terraform Provider for ESS. Until then we are limited to using [create](https://www.terraform.io/docs/provisioners/index.html#creation-time-provisioners) and [destroy](https://www.terraform.io/docs/provisioners/index.html#destroy-time-provisioners) provisioners. There are no `update` provisioners based on the Terraform [codebase](https://github.com/hashicorp/terraform/blob/f281eb2b447dc3e3f7847295ccede2ce2c54297c/configs/provisioner.go#L177-L181) and [documentation](https://www.terraform.io/docs/provisioners/index.html).*

## Unsupported Scenarios

Other [ELK Stack](https://www.elastic.co/what-is/elk-stack) services are not yet supported by this module. However, they may be supported based on subsequent design and implementation spikes. Other ELK services include:

- [APM](https://www.elastic.co/guide/en/apm/get-started/2.4/overview.html)
- [Kibana](https://www.elastic.co/guide/en/apm/get-started/2.4/overview.html)
- [Logstash](https://www.elastic.co/guide/en/logstash/2.4/index.html)

---

## Usage

### Pre-requisites

This module assumes that an account for ESS has been setup. There are instructions to do this located on https://www.elastic.co/.
You will need to provide the following information in order to authenticate with ESS:

- API Key, Bearer Token or Basic Auth header. Documentation for this is TBD.

### Module Usage

``` json
module "elastic_cluster" {
  source                      = "../elastic-search-service/"
  cloud                       = "azure"
  region                      = "eastus2"
  name                        = "foo deployment"
  auth_token                  = "********"
  auth_type                   = "..."
  deployment_template_id      = "azure-io-optimized"
  deployment_configuration_id = "azure.data.highio.l32sv2"

  elasticsearch = {
    version = "6.8.7"
    cluster_topology = {
      memory_per_node     = 1024
      node_count_per_zone = 1
      zone_count          = 1
      node_type = {
        data   = true
        ingest = true
        master = true
        ml     = false
      }
    }
  }
}

output "cluster_properties" {
  description = "Properties of the deployed cluster"
  value       = module.elastic_cluster.cluster_properties
}

```

### Variables

See [variables.tf](./variables.tf) for a full description of all the configuration values that are supported.

### Outputs

``` json
output "cluster_properties" {
  description = "Properties of the deployed cluster"
  type        = object({
    elastic_search = object({
      cluster_id  = string
      username    = string
      password    = string
      endpoint    = string
    })
  })
}
```

## Implementation Strategy

This module is different from most in that there is no underlying Terraform provider that can be used to provision resources in any of Elastic's products. Because of this we have decided to provision resources using shell scripts (located in the [scripts](./scripts) directory). The script is **unix** compatible and will not work on Windows without using WSL.

Elastic has indicated that a Terraform Provider for Elastic products is in the works. At that time, this module should be updated to leverage the native Terraform provider as it will be easier to maintain in the long term and will also support resource updates.
