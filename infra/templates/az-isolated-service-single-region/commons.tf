module "provider" {
  source = "../../modules/providers/azure/provider"
}

locals {
  prefix        = "${lower(var.name)}-${lower(terraform.workspace)}"
  admin_rg_name = "${local.prefix}-admin-rg"                 // name of resource group used for admin resources
  app_rg_name   = "${local.prefix}-app-rg"                   // name of app resource group
  sp_name       = "${local.prefix}-sp"                       // name of service plan
  ai_name       = "${local.prefix}-ai"                       // name of app insights
  kv_name       = format("%.20s-kv", local.prefix)           // name of key vault
  acr_name      = replace("${local.prefix}acr", "/\\W/", "") // name of acr
  // id of App Service Environment
  ase_id = "/subscriptions/${var.ase_subscription_id}/resourceGroups/${var.ase_resource_group}/providers/Microsoft.Web/hostingEnvironments/${var.ase_name}"
}
