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
