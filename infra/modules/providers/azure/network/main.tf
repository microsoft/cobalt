module "azure-provider" {
  source = "../provider"
}

data "azurerm_resource_group" "vnet" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = data.azurerm_resource_group.vnet.location
  resource_group_name = data.azurerm_resource_group.vnet.name
  address_space       = var.address_space
}


resource "azurerm_subnet" "subnet" {
  count                = length(var.subnets)
  name                 = var.subnets[count.index].name
  resource_group_name  = data.azurerm_resource_group.vnet.name
  address_prefix       = var.subnets[count.index].address_prefix
  virtual_network_name = var.vnet_name
  service_endpoints    = var.subnets[count.index].service_endpoints

  delegation {
    name = var.subnets[count.index].delegation.name
    service_delegation {
      name    = var.subnets[count.index].delegation.service_delegation.name
      actions = var.subnets[count.index].delegation.service_delegation.actions
    }
  }

  depends_on = [azurerm_virtual_network.vnet]
}
