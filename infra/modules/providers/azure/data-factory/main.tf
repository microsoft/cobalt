module "azure-provider" {
  source = "../provider"
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "azurerm_data_factory" "main" {
  #required
  name                = var.data_factory_name
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location

  # This will be static as "SystemAssigned" is the only identity available now
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_factory_integration_runtime_managed" "main" {
  name                             = var.data_factory_runtime_name
  data_factory_name                = azurerm_data_factory.main.name
  resource_group_name              = data.azurerm_resource_group.main.name
  location                         = data.azurerm_resource_group.main.location
  node_size                        = var.node_size
  number_of_nodes                  = var.number_of_nodes
  edition                          = var.edition
  max_parallel_executions_per_node = var.max_parallel_executions_per_node

  vnet_integration {
    vnet_id     = var.vnet_integration.vnet_id
    subnet_name = var.vnet_integration.subnet_name
  }
}

resource "azurerm_data_factory_pipeline" "main" {
  name                = var.data_factory_pipeline_name
  resource_group_name = data.azurerm_resource_group.main.name
  data_factory_name   = azurerm_data_factory.main.name
}

resource "azurerm_data_factory_trigger_schedule" "main" {
  name                = var.data_factory_trigger_name
  data_factory_name   = azurerm_data_factory.main.name
  resource_group_name = data.azurerm_resource_group.main.name
  pipeline_name       = azurerm_data_factory_pipeline.main.name

  interval  = var.data_factory_trigger_interval
  frequency = var.data_factory_trigger_frequency
}
