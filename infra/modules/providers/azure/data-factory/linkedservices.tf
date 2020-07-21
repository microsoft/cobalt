
resource "azurerm_data_factory_linked_service_sql_server" "main" {
  name                     = var.data_factory_linked_sql_name
  resource_group_name      = data.azurerm_resource_group.main.name
  data_factory_name        = azurerm_data_factory.main.name
  connection_string        = var.data_factory_linked_sql_connection_string
  integration_runtime_name = azurerm_data_factory_integration_runtime_managed.main.name
}
