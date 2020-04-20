variable "cloud" {
  description = "The cloud to deploy to. Options are 'azure', 'gcp' and 'aws'"
  type        = string
}

variable "region" {
  description = "The region to deploy to. The valid options for this variable depend on the target cloud"
  type        = string
}

variable "elasticsearch" {
  description = "Settings for defining a cluster"
  type = object({
    version = string
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

variable "name" {
  description = "The name of the deployment"
  type        = string
}

variable "deployment_template_id" {
  description = <<EOF
The name of the deployment template. Valid values for Azure are:
  azure-io-optimized
  azure-compute-optimized
  azure-memory-optimized
  azure-hot-warm
  azure-cross-cluster-search
  default
EOF
  type        = string
}

variable "deployment_configuration_id" {
  description = <<EOF
  The configuration ID for the template. The valid values depend on the deployment_template_id and are enumerated here:
  azure-io-optimized
    azure.data.highio.l32sv2
    azure.master.e32sv3
    azure.ml.d64sv3
    azure.kibana.e32sv3
    azure.apm.e32sv3
  azure-compute-optimized
    azure.data.highcpu.d64sv3
    azure.master.e32sv3
    azure.ml.d64sv3
    azure.kibana.e32sv3
    azure.apm.e32sv3
  azure-memory-optimized
    azure.data.highmem.e32sv3
    azure.master.e32sv3
    azure.ml.d64sv3
    azure.kibana.e32sv3
    azure.apm.e32sv3
  azure-hot-warm
    azure.data.highio.l32sv2
    azure.data.highstorage.e16sv3
    azure.master.e32sv3
    azure.ml.d64sv3
    azure.kibana.e32sv3
    azure.apm.e32sv3
  azure-cross-cluster-search
    azure.ccs.e32sv3
    azure.ml.d64sv3
    azure.kibana.e32sv3
  default
    azure.data.highio.l32sv2
    azure.master.e32sv3
    azure.ml.d64sv3
    azure.kibana.e32sv3
    azure.apm.e32sv3
EOF
  type        = string
}

variable "auth_token" {
  description = "Authentication token"
  type        = string
}

variable "auth_type" {
  description = "Type of auth to use. Options are 'ApiKey' or 'Basic' or 'Bearer'"
  type        = string
  default     = "ApiKey"
}