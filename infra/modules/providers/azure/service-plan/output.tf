output "service_plan_name" {
  description = "The name of the service plan created"
  value       = azurerm_app_service_plan.svcplan.name
}

output "service_plan_kind" {
  description = "The kind of service plan created"
  value       = azurerm_app_service_plan.svcplan.kind
}

output "app_service_plan_id" {
  value = azurerm_app_service_plan.svcplan.id
}

