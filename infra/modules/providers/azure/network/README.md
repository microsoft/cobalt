# Network

This Terraform module template provide a vnet and subnet resources in Azure for the given resource group. 

Information about Azure virtual network can be found [here](https://docs.microsoft.com/en-us/azure/virtual-network/) as well as for the subnet  [here](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-manage-subnet#add-a-subnet)

## Current Features:

- Provisions a virtual network resource for a given resource group
- Provisions a set of subnets for the created VNet

## Usage Example

Virtual network (vnet) usage example:

```hcl

module "network" {
  source              = "../../modules/providers/azure/network"
  vnet_name           = var.vnet_name
  resource_group_name = data.azurerm_resource_group.vnet.name
  location            = data.azurerm_resource_group.vnet.location
  address_space       = azurerm_virtual_network.address_space
  subnet_names = ["subnet1","subent2"]
  subnet_prefixes = ["10.0.1.0/24","10.0.2.0/24"]
}
```

## Outputs

Once the deployments are completed successfully, the output for the current module will be in the format mentioned below:


```
virtual_network_id = (xxx.x.x.x, ...)

subnet_ids = (xxx.x.x.x, ...)

```

## Argument Reference

Supported arguments for this module are available in [variables.tf](./variables.tf). 
More resources on this module are provided [here](https://www.terraform.io/docs/providers/azurerm/r/virtual_network.html) and  [here](https://www.terraform.io/docs/providers/azurerm/r/subnet.html)

