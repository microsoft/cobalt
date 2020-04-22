# Make sure to set the following environment variables:
#   AZDO_PERSONAL_ACCESS_TOKEN
#   AZDO_ORG_SERVICE_URL
provider "azuredevops" {
  version = ">= 0.0.1"
}

provider "null" {
  version = "2.1.2"
}

// use the following two block (a `resource` and a `local` block) to
// use an existing Azure DevOps Project.
//
//data "azuredevops_projects" "p" {
//  project_name = var.project_name
//}
//
//locals {
//  project_name = data.azuredevops_projects.p.projects.*.name[0]
//  project_id   = data.azuredevops_projects.p.projects.*.project_id[0]
//}

// use the following two block (a `resource` and a `local` block) to
// create a new Azure DevOps Project.

resource "azuredevops_project" "p" {
  project_name = var.project_name
}

locals {
  project_name = azuredevops_project.p.project_name
  project_id   = azuredevops_project.p.id
}

resource "azuredevops_variable_group" "core_vg" {
  project_id   = local.project_id
  name         = "Infrastructure Pipeline Variables"
  description  = "Managed by Terraform"
  allow_access = true

  variable {
    name  = "AGENT_POOL"
    value = "Hosted Ubuntu 1604"
  }
  variable {
    name  = "BUILD_ARTIFACT_NAME"
    value = "drop"
  }
  variable {
    name  = "FORCE_RUN"
    value = "False"
  }
  variable {
    name  = "SERVICE_CONNECTION_NAME"
    value = azuredevops_serviceendpoint_azurerm.endpointazure.service_endpoint_name
  }
}

resource "azuredevops_variable_group" "stage_vg" {
  project_id   = local.project_id
  count        = length(var.environments)
  name         = format("Infrastructure Pipeline Variables - %s", var.environments[count.index].environment)
  description  = "Managed by Terraform"
  allow_access = false

  variable {
    name  = "ARM_SUBSCRIPTION_ID"
    value = var.environments[count.index].az_sub_id
  }
  variable {
    name  = "REMOTE_STATE_ACCOUNT"
    value = format("tf%s", var.environments[count.index].environment)
  }
  variable {
    name  = "REMOTE_STATE_CONTAINER"
    value = local.tf_state_container_name
  }
}

resource "azuredevops_variable_group" "secrets_vg" {
  project_id   = local.project_id
  count        = length(var.environments)
  name         = format("Infrastructure Pipeline Secrets - %s", var.environments[count.index].environment)
  description  = "Managed by Terraform"
  allow_access = false

  variable {
    name  = "PLACEHOLDER"
    value = "placeholder"
  }
}

resource "azuredevops_git_repository" "repo" {
  project_id = local.project_id
  name       = "Infrastructure Repository"
  initialization {
    init_type = "Clean"
  }
}

resource "azuredevops_build_definition" "build" {
  project_id = local.project_id
  name       = "Infrastructure CICD"

  repository {
    repo_type   = "TfsGit"
    repo_name   = azuredevops_git_repository.repo.name
    branch_name = azuredevops_git_repository.repo.default_branch
    yml_path    = "devops/providers/azure-devops/templates/azure-pipelines.yml"
  }

  variable_groups = concat(
    [azuredevops_variable_group.core_vg.id],
    azuredevops_variable_group.stage_vg.*.id,
    azuredevops_variable_group.secrets_vg.*.id
  )
}

resource "azuredevops_serviceendpoint_azurerm" "endpointazure" {
  project_id                = local.project_id
  service_endpoint_name     = "Infrastructure Deployment Service Connection"
  azurerm_spn_clientid      = azuread_service_principal.sp.application_id
  azurerm_spn_clientsecret  = random_string.random.result
  azurerm_spn_tenantid      = data.azurerm_subscription.sub.tenant_id
  azurerm_subscription_id   = data.azurerm_subscription.sub.subscription_id
  azurerm_subscription_name = data.azurerm_subscription.sub.display_name
  azurerm_scope             = data.azurerm_subscription.sub.id
}
