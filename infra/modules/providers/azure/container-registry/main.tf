data "azurerm_resource_group" "container_registry" {
  name = var.resource_group_name
}

data "azurerm_client_config" "current" {}


resource "azurerm_container_registry" "container_registry" {
  name                = var.container_registry_name
  resource_group_name = data.azurerm_resource_group.container_registry.name
  location            = data.azurerm_resource_group.container_registry.location
  sku                 = var.container_registry_sku
  admin_enabled       = var.container_registry_admin_enabled
  tags                = var.container_registry_tags

  # This dynamic block configures a default DENY action to all incoming traffic
  # in the case that one of the following hold true:
  #   1: IP whitelist has been configured
  #   2: Subnet whitelist has been configured
  dynamic "network_rule_set" {
    for_each = length(concat(var.resource_ip_whitelist, var.subnet_id_whitelist)) == 0 ? [] : [var.resource_ip_whitelist]
    content {
      default_action = "Deny"
      # This dynamic block configures "Allow" action to all of the whitelisted IPs. It is only
      # stamped out in the case that there are IPs configured for whitelist
      dynamic "ip_rule" {
        for_each = var.resource_ip_whitelist
        content {
          action   = "Allow"
          ip_range = ip_rule.value
        }
      }
      dynamic "virtual_network" {
        for_each = var.subnet_id_whitelist
        content {
          action    = "Allow"
          subnet_id = virtual_network.value
        }
      }
    }
  }

}