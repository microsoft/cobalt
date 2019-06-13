output "service_principal_object_id" {
  description = "The ID of the Azure AD Service Principal"
  value       = "${azuread_service_principal.sp.*.object_id}"
}

output "service_principal_application_id" {
  description = "The ID of the Azure AD Application"
  value       = "${azuread_service_principal.sp.*.application_id}"
}

output "service_principal_display_name" {
  description = "The Display Name of the Azure AD Application associated with this Service Principal"
  value       = "${azuread_service_principal.sp.*.display_name}"
}
