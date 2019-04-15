output "svc_plan_name" {
  description = "The name of the service plan created"
  value       = "${azurerm_app_service_plan.svcplan.name}"
}

output "svc_plan_kind" {
  description = "The kind of service plan created"
  value = "${azurerm_app_service_plan.svcplan.kind}"
}