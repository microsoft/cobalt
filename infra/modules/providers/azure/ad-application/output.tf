output "application_id" {
  description = "The client id output by the app registration."
  value       = azuread_application.auth.*.application_id
}

output "azuread_config_data" {
  description = "Output data that pairs azuread names with their client ids."
  value = {
    for azuread in data.azuread_application.auth :
    azuread.name => {
      client_id = azuread.application_id
    }
  }
}
