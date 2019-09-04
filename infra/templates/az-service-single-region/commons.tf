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
  base_name     = "${local.app_id}-${local.ws_name}${local.suffix}"
  base_name_21  = length(local.base_name) < 22 ? local.base_name : "${substr(local.base_name, 0, 21 - length(local.suffix))}${local.suffix}"
  base_name_46  = length(local.base_name) < 47 ? local.base_name : "${substr(local.base_name, 0, 46 - length(local.suffix))}${local.suffix}"
  base_name_60  = length(local.base_name) < 61 ? local.base_name : "${substr(local.base_name, 0, 60 - length(local.suffix))}${local.suffix}"
  base_name_76  = length(local.base_name) < 77 ? local.base_name : "${substr(local.base_name, 0, 76 - length(local.suffix))}${local.suffix}"
  base_name_83  = length(local.base_name) < 84 ? local.base_name : "${substr(local.base_name, 0, 83 - length(local.suffix))}${local.suffix}"

  // Resource names
  admin_rg_name    = "${local.base_name_83}-adm-rg"               // resource group used for admin resources (max 90 chars)
  app_rg_name      = "${local.base_name_83}-app-rg"               // app resource group (max 90 chars)
  sp_name          = "${local.base_name}-sp"                      // service plan
  ai_name          = "${local.base_name}-ai"                      // app insights
  kv_name          = "${local.base_name_21}-kv"                   // key vault (max 24 chars)
  acr_name         = "${replace(local.base_name_46, "-", "")}acr" // container registry (max 50 chars, alphanumeric *only*)
  vnet_name        = "${local.base_name_60}-net"                  // virtual network (max 64 chars)
  tm_profile_name  = "${local.base_name_60}-tf"                   // traffic manager profile (max 63 chars)
  tm_endpoint_name = "${local.region}_${local.app_id}"            // traffic manager endpoint
  tm_dns_name      = "${local.base_name}-dns"                     // traffic manager dns relative name
  appgateway_name  = "${local.base_name_76}-gw"                   // app gateway (max 80 chars)
  public_pip_name  = "${local.base_name_76}-ip"                   // public IP (max 80 chars)

  // Resolved TF Vars
  resolved_acr_rg_name = var.azure_container_resource_group == "" ? azurerm_resource_group.svcplan.name : var.azure_container_resource_group
  resolved_acr_name    = var.azure_container_resource_name == "" ? local.acr_name : var.azure_container_resource_name
}

