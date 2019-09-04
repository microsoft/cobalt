module "provider" {
  source = "../../modules/providers/azure/provider"
}

resource "random_string" "workspace_scope" {
  keepers = {
    # Generate a new id each time we switch to a new workspace or app id
    ws_name = replace(trimspace(lower(terraform.workspace)), "_", "-")
    app_id  = replace(trimspace(lower(var.name)), "_", "-")
  }

  length = max(1, var.randomization_level) // error for zero-length
  special = false
  upper = false
}

locals {
  // sanitize names
  app_id  = random_string.workspace_scope.keepers.app_id
  region = replace(trimspace(lower(var.resource_group_location)), "_", "-")
  ws_name = random_string.workspace_scope.keepers.ws_name
  suffix = var.randomization_level > 0 ? "-${random_string.workspace_scope.result}" : ""

  // base name for resources, name constraints documented here: https://docs.microsoft.com/en-us/azure/architecture/best-practices/naming-conventions
  base_name     = "${local.app_id}-${local.ws_name}${suffix}"
  base_name_21  = length(local.base_name) < 22 ? local.base_name : "${substr(replace(local.app_id, "-", ""), 0, 10)}-${substr(replace(local.ws_name, "-", ""), 0, 10)}${suffix}"
  base_name_46  = length(local.base_name) < 47 ? local.base_name : "${substr(replace(local.app_id, "-", ""), 0, 25)}-${substr(replace(local.ws_name, "-", ""), 0, 20)}${suffix}"
  base_name_60  = length(local.base_name) < 61 ? local.base_name : "${substr(replace(local.app_id, "-", ""), 0, 34)}-${substr(replace(local.ws_name, "-", ""), 0, 25)}${suffix}"
  base_name_76  = length(local.base_name) < 77 ? local.base_name : "${substr(replace(local.app_id, "-", ""), 0, 45)}-${substr(replace(local.ws_name, "-", ""), 0, 30)}${suffix}"
  base_name_83  = length(local.base_name) < 84 ? local.base_name : "${substr(replace(local.app_id, "-", ""), 0, 52)}-${substr(replace(local.ws_name, "-", ""), 0, 30)}${suffix}"

  // Resolved resource names
  app_rg_name      = "${local.base_name_83}-app-rg"               // app resource group (max 90 chars)
  sp_name          = "${local.base_name}-sp"                      // service plan

  // Resolved TF Vars
  reg_url          = var.docker_registry_server_url
  app_services     = {
    for target in var.deployment_targets :
    target.app_name => {
      image = "${target.image_name}:${target.image_release_tag_prefix}"
    }
  }
}