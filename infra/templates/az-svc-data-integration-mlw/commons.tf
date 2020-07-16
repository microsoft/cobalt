module "provider" {
  source = "../../modules/providers/azure/provider"
}

data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

resource "random_string" "workspace_scope" {
  keepers = {
    # Generate a new id each time we switch to a new workspace or app id
    ws_name = replace(trimspace(lower(terraform.workspace)), "_", "-")
    app_id  = replace(trimspace(lower(var.prefix)), "_", "-")
  }

  length  = max(1, var.randomization_level) // error for zero-length
  special = false
  upper   = false
}

locals {
  // sanitize names
  resource_prefix   = replace(format("%s-%s", trimspace(lower(terraform.workspace)), random_string.workspace_scope.result), "_", "-")
  app_id            = random_string.workspace_scope.keepers.app_id
  region            = replace(trimspace(lower(var.resource_group_location)), "_", "-")
  ws_name           = random_string.workspace_scope.keepers.ws_name
  suffix            = var.randomization_level > 0 ? "-${random_string.workspace_scope.result}" : ""
  base_storage_name = "${substr(replace(local.resource_prefix, "-", ""), 0, 10)}st" // storage account
  sys_storage_name  = "ml${local.base_storage_name}"                                //mlops storage account
  app_storage_name  = "dp${local.base_storage_name}"                                //dataprep storage account

  // base name for resources, name constraints documented here: https://docs.microsoft.com/en-us/azure/architecture/best-practices/naming-conventions
  base_name    = length(local.app_id) > 0 ? "${local.ws_name}${local.suffix}-${local.app_id}" : "${local.ws_name}${local.suffix}"
  base_name_21 = length(local.base_name) < 22 ? local.base_name : "${substr(local.base_name, 0, 21 - length(local.suffix))}${local.suffix}"
  base_name_46 = length(local.base_name) < 47 ? local.base_name : "${substr(local.base_name, 0, 46 - length(local.suffix))}${local.suffix}"
  base_name_60 = length(local.base_name) < 61 ? local.base_name : "${substr(local.base_name, 0, 60 - length(local.suffix))}${local.suffix}"
  base_name_70 = length(local.base_name) < 70 ? local.base_name : "${substr(local.base_name, 0, 70 - length(local.suffix))}${local.suffix}"
  base_name_76 = length(local.base_name) < 77 ? local.base_name : "${substr(local.base_name, 0, 76 - length(local.suffix))}${local.suffix}"
  base_name_83 = length(local.base_name) < 84 ? local.base_name : "${substr(local.base_name, 0, 83 - length(local.suffix))}${local.suffix}"

  tenant_id = data.azurerm_client_config.current.tenant_id

  // Resource names
  app_rg_name                 = "${local.base_name_83}-app-rg"             // app resource group (max 90 chars)
  admin_rg_lock               = "${local.base_name_83}-adm-rg-delete-lock" // management lock to prevent deletes
  app_rg_lock                 = "${local.base_name_83}-app-rg-delete-lock" // management lock to prevent deletes
  func_app_sp_name            = "${local.base_name}-sp-fa"                 // service plan
  ai_name                     = "${local.base_name}-ai"                    // app insights
  mlw_ai_name                 = "${local.base_name}-mlw-ai"                // ml app insights
  ad_app_name                 = "${local.base_name}-ad-app"                //service principal
  ad_app_management_name      = "${local.base_name}-ad-app-management"
  graph_id                    = "00000003-0000-0000-c000-000000000000"       // ID for Microsoft Graph API
  graph_role_id               = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"       // ID for User.Read API
  kv_name                     = "${local.base_name_21}-kv"                   // key vault (max 24 chars)
  acr_name                    = "${replace(local.base_name_46, "-", "")}acr" // container registry (max 50 chars, alphanumeric *only*)
  vnet_name                   = "vnet-${local.base_name_60}"                 // virtual network (max 64 chars)    
  subnet_name                 = "snet-${local.base_name_76}"                 // subnet (max 76 chars)
  function_subnet_name        = "snet-func-${local.base_name_76}"            // subnet (max 76 chars)
  func_subnet_delegation_name = "${local.base_name_21}"                      // subnet (max 76 chars)
  mlw_name                    = "${local.base_name_21}-mlw"                  // workspace (max 30 chars)
  mlw_rg_name                 = "${local.base_name_83}-mlw-rg"               // mlw resource group (max 90 chars)
  public_pip_name             = "${local.base_name_76}-ip"                   // public IP (max 80 chars)
  svc_princ_name              = "${local.base_name}-svc-principal"           // service principal
  acr_svc_princ_name          = "${local.base_name}-acr-svc-principal"       // container registry service principal
  app_svc_name_prefix         = local.base_name_21
  auth_svc_name_prefix        = "${local.base_name_21}-au"
  smpl_app_postfix            = "app"
  data_factory_name           = "adf-cares-${local.base_name_46}"
  data_factory_runtime_name   = "adf-rt-cares-${local.base_name_46}"
  data_factory_pipeline_name  = "adf-pipeline-cares-${local.base_name_83}"
  data_factory_trigger_name   = "adf-trigger-cares-${local.base_name_83}"
  func_app_name_prefix        = "func-cares-${local.base_name_46}"      // Function app name (Max 60 chars)
  cosmos_account_name         = "cosmos-cares-${local.base_name_21}"    // Cosmos databse account name (max 44 chars)
  cosmos_db_name              = "cosmos-cares-db-${local.base_name_21}" // Cosmos databse account name (max 44 chars)

  app_service_global_config = {
    aad_client_id       = format(local.app_setting_kv_format, local.output_secret_map.aad-client-id)
    appinsights_key     = format(local.app_setting_kv_format, local.output_secret_map.appinsights-key)
    smpl_app_endpoint   = format("https://%s-%s.azurewebsites.net", local.auth_svc_name_prefix, lower(local.smpl_app_postfix))
    storage_account     = module.sys_storage_account.name
    storage_account_key = format(local.app_setting_kv_format, local.output_secret_map.sys-storage-account-key)
  }

  mlw_service_global_config = {
    mlw-appinsights-key = format(local.app_setting_kv_format, local.output_secret_map.mlw-appinsights-key)
    storage_account     = module.sys_storage_account.name
    storage_account_key = format(local.app_setting_kv_format, local.output_secret_map.sys-storage-account-key)
  }

  func_app_settings = {
    clientId                       = format(local.app_setting_kv_format, local.output_secret_map.app-sp-username)
    clientKey                      = format(local.app_setting_kv_format, local.output_secret_map.app-sp-password)
    storageKey                     = format(local.app_setting_kv_format, local.output_secret_map.app-storage-account-key)
    storageName                    = module.app_storage_account.name
    tenantId                       = format(local.app_setting_kv_format, local.output_secret_map.app-sp-tenant-id)
    statusPollingInterval          = ""
    waitUntil                      = ""
    dataDriftContainer             = module.app_storage_account.containers.acidatadriftdata.name
    APPINSIGHTS_INSTRUMENTATIONKEY = format(local.app_setting_kv_format, local.output_secret_map.appinsights-key)
  }

  subnets = [
    {
      name                = local.subnet_name
      resource_group_name = azurerm_resource_group.app_rg.name
      address_prefix      = var.subnet_address_prefix
      service_endpoints   = var.subnet_service_endpoints
      delegation = {
        name = local.func_subnet_delegation_name
        service_delegation = {
          name    = "Microsoft.Web/serverFarms"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    },
    {
      name                = local.function_subnet_name
      resource_group_name = azurerm_resource_group.app_rg.name
      address_prefix      = var.function_subnet_address_prefix
      service_endpoints   = var.func_subnet_service_endpoints
      delegation = {
        name = ""
        service_delegation = {
          name    = "Microsoft.Web/serverFarms"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    }
  ]

}
