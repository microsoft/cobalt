
#locals {
#  tf_vars_file = <<EOF
#env="${var.environment_name}"
#resource_group="${azurerm_resource_group.rg.name}"
#acr_id="${var.acr_id}"
#EOF
#}

resource "github_actions_secret" "sp_client_id" {
  repository      = "gh-actions-tf-bedrock"
  secret_name     = format("%s_ARM_CLIENT_ID", upper(var.environment_name))
  plaintext_value = azuread_service_principal.sp.application_id
}

resource "github_actions_secret" "sp_client_secret" {
  repository      = "gh-actions-tf-bedrock"
  secret_name     = format("%s_ARM_CLIENT_SECRET", upper(var.environment_name))
  plaintext_value = random_password.sp.result
}

#resource "gitlab_project_variable" "tf_vars_file" {
#project           = var.gitlab_terraform_project_path
#key               = format("%s_TF_VARS", upper(var.environment_name))
#value             = local.tf_vars_file
#variable_type     = "file"
#protected         = false
#environment_scope = var.environment_name
#}

#resource "gitlab_project_variable" "storage_account" {
#project           = var.gitlab_terraform_project_path
#key               = format("%s_AZURE_STORAGE_ACCOUNT_NAME", upper(var.environment_name))
#value             = var.backend_storage_account_name
#protected         = false
#masked            = true
#environment_scope = var.environment_name
#}

#resource "gitlab_project_variable" "storage_container" {
#project           = var.gitlab_terraform_project_path
#key               = format("%s_AZURE_STORAGE_ACCOUNT_CONTAINER", upper(var.environment_name))
#value             = azurerm_storage_container.tfstate.name
#protected         = false
#masked            = true
#environment_scope = var.environment_name
#}

#resource "gitlab_project_variable" "storage_subscription" {
#project           = var.gitlab_terraform_project_path
#key               = format("%s_AZURE_STORAGE_ACCOUNT_SUBSCRIPTION", upper(var.environment_name))
#value             = var.subscription_id
#protected         = false
#masked            = true
#environment_scope = var.environment_name
#}
