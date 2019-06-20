output "app_insights_app_id" {
  description = "The App ID associated with this Application Insights component"
  value       = azurerm_application_insights.appinsights.app_id
}

output "app_insights_instrumentation_key" {
  description = "The Instrumentation Key for this Application Insights component."
  value       = azurerm_application_insights.appinsights.instrumentation_key
  sensitive   = true
}

