output "svc_plan_name" {
  description = "The name of the service plan created"
  value       = "${azurerm_app_service_plan.svcplan.name}"
}

output "svc_plan_kind" {
  description = "The kind of service plan created"
  value = "${azurerm_app_service_plan.svcplan.kind}"
}

output "appsvc_name" {
  description = "The name of the app service created"
  value       = "${azurerm_app_service.appsvc.name}"
}

output "appsvc_uri" {
  description = "The URL of the app service created"
  value       = "${azurerm_app_service.appsvc.default_site_hostname}"
}
