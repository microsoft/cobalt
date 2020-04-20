output "service_principal_object_id" {
  description = "The ID of the Azure AD Service Principal"
  value       = azuread_service_principal.sp[0].object_id
}

output "service_principal_application_id" {
  description = "The ID of the Azure AD Application"
  value       = azuread_service_principal.sp[0].application_id
}

output "service_principal_display_name" {
  description = "The Display Name of the Azure AD Application associated with this Service Principal"
  value       = azuread_service_principal.sp[0].display_name
}

output "service_principal_password" {
  description = "The password of the generated service principal. This is only exported when create_for_rbac is true."
  value       = azuread_service_principal_password.sp[0].value
  sensitive   = true
}
