data "azuredevops_project" "project" {
  project_name = var.project_name
}

resource "azuredevops_variable_group" "variablegroup" {
  project_id   = data.azuredevops_project.project.id
  name         = var.variable_group_name
  description  = var.variable_group_description
  allow_access = var.allow_access

  dynamic "variable" {
    for_each = var.variables
    content {
      name      = variable.value.name
      value     = variable.value.value
      is_secret = variable.value.is_secret
    }
  }
}