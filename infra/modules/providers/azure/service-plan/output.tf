output "resource_group_name" {
  description = "The name of the resource group created"
  value = "${azurerm_resource_group.svcplan.name}"
}

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

output "public_ip_address" {
  value = "${azurerm_public_ip.appsvc.ip_address}"
}

output "load_balancer_name" {
  value = "${azurerm_lb.appsvc.name}"
}
