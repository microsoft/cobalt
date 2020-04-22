# Elastic Cloud Enterprise

This module simplifies provisioning [ELK Services](https://www.elastic.co/what-is/elk-stack) within a [Elastic Cloud Enterprise](https://www.elastic.co/products/ece) (ECE) cluster using Terraform.

## Intro to ECE

> Elastic Cloud Enterprise, or ECE, is the same product that powers the Elastic Cloud hosted offering, available for installation on the hardware and in the environment you choose. ECE can be deployed anywhere - on public or private clouds, virtual machines, or even on bare metal hardware. Because all services are containerized, they support a wide range of configurations.

## Supported Scenarios

- Provisioning [Elasticsearch](https://www.elastic.co/products/elastic-stack) clusters on ECE.

***Note**: Support will be for `CREATE` and `DELETE` scenarios until there exists a native Terraform Provider for ECE. Until then we are limited to using [create](https://www.terraform.io/docs/provisioners/index.html#creation-time-provisioners) and [destroy](https://www.terraform.io/docs/provisioners/index.html#destroy-time-provisioners) provisioners. There are no `update` provisioners based on the Terraform [codebase](https://github.com/hashicorp/terraform/blob/f281eb2b447dc3e3f7847295ccede2ce2c54297c/configs/provisioner.go#L177-L181) and [documentation](https://www.terraform.io/docs/provisioners/index.html).*

## Unsupported Scenarios

Other [ELK Stack](https://www.elastic.co/what-is/elk-stack) services are not yet supported by this module. However, they may be supported based on subsequent design and implementation spikes. Other ELK services include:

- [APM](https://www.elastic.co/guide/en/apm/get-started/2.4/overview.html)
- [Kibana](https://www.elastic.co/guide/en/apm/get-started/2.4/overview.html)
- [Logstash](https://www.elastic.co/guide/en/logstash/2.4/index.html)

---

## Usage

### Pre-requisites

This module assumes that an instance of ECE is already provisioned. Current supported version is 2.4. Detailed instructions for doing this [exist here](https://www.elastic.co/guide/en/cloud-enterprise/2.4/ece-getting-started.html).

You will need to provide the following information in order to authenticate with ECE:

- API Key. [Instructions for finding this](https://www.elastic.co/guide/en/cloud-enterprise/current/ece-restful-api-authentication.html)
- Coordinator Endpoint. This will look like `https://$HOST:$PORT` where `$HOST` is the IP address of the ECE coordinator and `$PORT` is the HTTP port on which the ECE service is listening.

### Module Usage

``` json
module "elastic_cluster" {
  source          = "../../modules/providers/elastic/elastic-cloud-enterprise"

  name            = "My Cluster Deployment"
  coordinator_url = "https://127.0.0.1:12443"

  auth_type  = "ApiKey"
  auth_token = "..."

  elasticsearch = {
    version = "6.8.3"
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
```

### Variables

``` json
variable "elasticsearch" {
  description = "Settings for defining a cluster"
  type =  object({
    version          = string
    cluster_topology = object({
      memory_per_node     = number
      node_count_per_zone = number
      zone_count          = number
      node_type = object({
        data   = bool
        ingest = bool
        master = bool 
        ml     = bool
      })
    })
  })
}
}

variable "name" {
  description = "The name of the deployment"
  type        = string
}

variable "coordinator_url" {
  description = "The coordinator URL"
  type        = string
}

variable "api_key" {
  description = "Api key"
  type        = string
}
```

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

## Appendix

### API Reference

For curious readers, you can find the full API reference for ECE [here](https://www.elastic.co/guide/en/cloud-enterprise/2.4/ece-restful-api-examples-create-deployment.html), though knowledge of this is not needed for clients of this module.

### API Examples

Request Example

``` json
curl -k -X POST -H "Authorization: ApiKey CLOUD_API_KEY" https://COORDINATOR_HOST:12443/api/v1/clusters/elasticsearch -H 'content-type: application/json' -d '{
  "cluster_name" : "My First Deployment",
  "plan" : {
      "elasticsearch" : {
          "version" : "7.0.1"
      },
      "cluster_topology" : [
          {
              "memory_per_node" : 2048,
              "node_count_per_zone" : 1,
              "node_type" : {
                 "data" : true,
                 "ingest" : true,
                 "master" : true,
                 "ml" : true
              },
              "zone_count" : 1
          }
      ]
  }
}'
```

Request Responce

``` json
{
  "elasticsearch_cluster_id": "$ELASTICSEARCH_CLUSTER_ID",
  "credentials": {
    "username": "elastic",
    "password": "$PASSWORD"
  }
}

```
