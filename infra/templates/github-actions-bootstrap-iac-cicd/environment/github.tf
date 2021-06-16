
locals {
  tf_vars_file = <<EOF
env="${var.environment_name}"
resource_group="${azurerm_resource_group.rg.name}"
acr_id="${var.acr_id}"
EOF
}

resource "github_actions_secret" "sp_client_id" {
  repository      = var.repository
  secret_name     = format("%s_ARM_CLIENT_ID", upper(var.environment_name))
  plaintext_value = azuread_service_principal.sp.application_id
}

resource "github_actions_secret" "sp_client_secret" {
  repository      = var.repository
  secret_name     = format("%s_ARM_CLIENT_SECRET", upper(var.environment_name))
  plaintext_value = random_password.sp.result
}

resource "github_actions_secret" "tf_vars_file" {
  repository      = var.repository
  secret_name     = format("%s_TF_VARS", upper(var.environment_name))
  plaintext_value = local.tf_vars_file
}

resource "github_actions_secret" "storage_account" {
  repository      = var.repository
  secret_name     = format("%s_AZURE_STORAGE_ACCOUNT_NAME", upper(var.environment_name))
  plaintext_value = var.backend_storage_account_name
}

resource "github_actions_secret" "storage_container" {
  repository      = var.repository
  secret_name     = format("%s_AZURE_STORAGE_ACCOUNT_CONTAINER", upper(var.environment_name))
  plaintext_value = azurerm_storage_container.tfstate.name
}

resource "github_actions_secret" "storage_subscription" {
  repository      = var.repository
  secret_name     = format("%s_AZURE_STORAGE_ACCOUNT_SUBSCRIPTION", upper(var.environment_name))
  plaintext_value = var.subscription_id
}
