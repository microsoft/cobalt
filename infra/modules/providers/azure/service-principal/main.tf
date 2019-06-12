module "azure-provider" {
  source = "../provider"
}

locals {
  rbac_true_false = "${var.create_for_rbac == "true" ? 1 : 0}"
}

data "azurerm_subscription" "sp" {}

resource "azuread_application" "sp" {
  count = "${local.rbac_true_false}"
  name = "iptfexample"
}

resource "azuread_service_principal" "sp" {
  count = "${local.rbac_true_false}"
  application_id = "${azuread_application.sp.application_id}"
}

resource "azurerm_role_assignment" "sp" {
  role_definition_name = "${var.role_name}"
  principal_id = "${var.create_for_rbac == "true" ? azuread_service_principal.sp.object_id : var.service_principle_object_id}"
  scope = "${var.role_scope}"
}
