output "rule_resource_id" {
  description = "The id of a metric alert rule."
  value       = azurerm_monitor_metric_alert.appmonitoring.*.id
}

