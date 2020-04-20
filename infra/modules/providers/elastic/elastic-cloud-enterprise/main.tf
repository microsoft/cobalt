//  Copyright © Microsoft Corporation
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

module "provider" {
  source = "../provider"
}

module "local_exec" {
  source  = "./local-exec-capture-stdout"
  command = format("bash %s/scripts/ese-deploy-create.sh", path.module)
  environment = {
    AUTH_TYPE         = var.auth_type
    AUTH_TOKEN        = var.auth_token
    COORDINATOR_URL   = var.coordinator_url
    DEPLOYMENT_NAME   = var.name
    ES_NODE_MEMORY    = var.elasticsearch.cluster_topology.memory_per_node
    ES_ZONE_COUNT     = var.elasticsearch.cluster_topology.zone_count
    ES_NODES_PER_ZONE = var.elasticsearch.cluster_topology.node_count_per_zone
    ES_VERSION        = var.elasticsearch.version
    ES_NODE_DATA      = var.elasticsearch.cluster_topology.node_type.data ? "true" : "false"
    ES_NODE_INGEST    = var.elasticsearch.cluster_topology.node_type.ingest ? "true" : "false"
    ES_NODE_MASTER    = var.elasticsearch.cluster_topology.node_type.master ? "true" : "false"
    ES_NODE_ML        = var.elasticsearch.cluster_topology.node_type.ml ? "true" : "false"
  }
}
