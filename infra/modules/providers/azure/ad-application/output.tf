output "azuread_config_data" {
  description = "Output data that pairs azuread names with their application ids."
  value = {
    for azuread in data.azuread_application.auth :
    azuread.name => {
      application_id = azuread.application_id
    }
  }
}
