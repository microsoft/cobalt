module "provider" {
  source = "../../modules/providers/azure/provider"
}

data "azurerm_subscription" "current" {}

locals {
  prefix        = "${lower(var.name)}-${lower(terraform.workspace)}"
  admin_rg_name = "${local.prefix}-admin-rg"                  // name of resource group used for admin resources
  app_rg_name   = "${local.prefix}-app-rg"                    // name of app resource group
  sp_name       = "${local.prefix}-sp"                        // name of service plan
  ai_name       = "${local.prefix}-ai"                        // name of app insights
  kv_name       = format("%.20s-kv", local.prefix)            // name of key vault
  acr_name      = replace("${local.prefix}azcr", "/\\W/", "") // name of acr
  ase_sub_id    = var.ase_subscription_id == "" ? data.azurerm_subscription.current.subscription_id : var.ase_subscription_id
  app_sub_id    = var.app_dev_subscription_id == "" ? data.azurerm_subscription.current.subscription_id : var.app_dev_subscription_id

  // id of App Service Environment
  ase_id = "/subscriptions/${local.ase_sub_id}/resourceGroups/${var.ase_resource_group}/providers/Microsoft.Web/hostingEnvironments/${var.ase_name}"
}
