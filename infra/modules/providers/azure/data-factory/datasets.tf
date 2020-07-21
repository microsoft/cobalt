
resource "azurerm_data_factory_dataset_sql_server_table" "main" {
  name                = var.data_factory_dataset_sql_name
  resource_group_name = data.azurerm_resource_group.main.name
  data_factory_name   = azurerm_data_factory.main.name
  linked_service_name = azurerm_data_factory_linked_service_sql_server.main.name
  table_name          = var.data_factory_dataset_sql_table_name
}