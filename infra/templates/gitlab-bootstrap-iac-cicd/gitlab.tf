locals {
  docker_auth      = base64encode(join(":", [azuread_service_principal.acr.application_id, random_password.acr.result]))
  docker_auth_json = <<EOF
{
    "auths": {
        "${azurerm_container_registry.acr.login_server}": {
            "auth": "${local.docker_auth}"
        }
    }
}
EOF
}

data "gitlab_group" "group" {
  full_path = var.group_path
}

resource "gitlab_group_variable" "registry" {
  group     = data.gitlab_group.group.id
  key       = "CI_REGISTRY"
  value     = azurerm_container_registry.acr.login_server
  protected = false
  masked    = true
}

resource "gitlab_group_variable" "registry_user" {
  group     = data.gitlab_group.group.id
  key       = "CI_REGISTRY_USER"
  value     = azuread_service_principal.acr.application_id
  protected = false
  masked    = true
}

resource "gitlab_group_variable" "registry_password" {
  group     = data.gitlab_group.group.id
  key       = "CI_REGISTRY_PASSWORD"
  value     = random_password.acr.result
  protected = false
  masked    = true
}

resource "gitlab_group_variable" "docker_auth" {
  group     = data.gitlab_group.group.id
  key       = "DOCKER_AUTH_CONFIG"
  value     = local.docker_auth_json
  protected = false
}

resource "gitlab_project_variable" "sub_id" {
  project           = var.gitlab_terraform_project_path
  key               = "ARM_SUBSCRIPTION_ID"
  value             = data.azurerm_client_config.current.subscription_id
  protected         = false
  masked            = true
  environment_scope = "*"
}

resource "gitlab_project_variable" "tenant_id" {
  project           = var.gitlab_terraform_project_path
  key               = "ARM_TENANT_ID"
  value             = data.azurerm_client_config.current.tenant_id
  protected         = false
  masked            = true
  environment_scope = "*"
}

resource "gitlab_project_variable" "storage_key" {
  project           = var.gitlab_terraform_project_path
  key               = "ARM_ACCESS_KEY"
  value             = azurerm_storage_account.ci.primary_access_key
  protected         = false
  masked            = true
  environment_scope = "*"
}
