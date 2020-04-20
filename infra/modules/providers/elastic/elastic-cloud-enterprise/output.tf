output "cluster_properties" {
  description = "Properties of the deployed cluster"
  value = {
    elastic_search = {
      cluster_id = module.local_exec.output["cluster_id"]
      username   = module.local_exec.output["cluster_username"]
      password   = module.local_exec.output["cluster_password"]
      endpoint   = module.local_exec.output["cluster_endpoint"]
    }
  }
}
