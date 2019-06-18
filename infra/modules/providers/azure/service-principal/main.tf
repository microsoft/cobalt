module "azure-provider" {
  source = "../provider"
}

locals {
  sps_to_create = var.create_for_rbac == true ? 1 : 0
}

data "azurerm_subscription" "sp" {
}

resource "azuread_application" "sp" {
  count = local.sps_to_create
  name  = var.display_name
}

resource "azuread_service_principal" "sp" {
  count          = local.sps_to_create
  application_id = azuread_application.sp[0].application_id
}

resource "azurerm_role_assignment" "sp" {
  role_definition_name = var.role_name
  principal_id         = var.create_for_rbac == true ? azuread_service_principal.sp[0].object_id : var.object_id
  scope                = var.role_scope
}
