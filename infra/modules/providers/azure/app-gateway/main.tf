data "azurerm_resource_group" "appgateway" {
  name      = "${var.resource_group_name}"
}

data "azurerm_virtual_network" "appgateway" {
    name                = "${var.virtual_network_name}"
    resource_group_name = "${data.azurerm_resource_group.appgateway.name}"
}
data "azurerm_subnet" "appgateway" {
    name                    = "${var.subnet_name}"
    resource_group_name     = "${data.azurerm_resource_group.appgateway.name}"
    virtual_network_name    = "${data.azurerm_virtual_network.appgateway.name}"
}

resource "azurerm_application_gateway" "appgateway" {
  name                = "${var.appgateway_name}"
  resource_group_name = "${data.azurerm_resource_group.appgateway.name}"
  location            = "${data.azurerm_resource_group.appgateway.location}"
  tags                = "${var.resource_tags}"

  sku {
    name     = "${var.appgateway_sku_name}"
    tier     = "${var.appgateway_tier}"
    capacity = "${var.appgateway_capacity}"
  }

  gateway_ip_configuration {
    name      = "${var.appgateway_ipconfig_name}"
    subnet_id = "${data.azurerm_subnet.appgateway.id}"
  }

  frontend_port {
    name = "${var.appgateway_frontend_port_name}"
    port = "${var.frontend_http_port}"
  }

  frontend_ip_configuration {
    name                  = "${var.appgateway_frontend_ip_configuration_name}"
    subnet_id             = "${var.frontend_ip_config_subnet_id}"
    private_ip_address    = "${var.frontend_ip_config_private_ip_address}"
    public_ip_address_id  = "${var.frontend_ip_config_public_ip_address_id}"
  }

  backend_address_pool {
    name         = "${var.appgateway_backend_address_pool_name}"
    ip_addresses = "${var.appgateway_backend_address_pool_ipaddresses}"
  }

  backend_http_settings {
    name                  = "${var.appgateway_backend_http_setting_name}"
    cookie_based_affinity = "${var.backend_http_cookie_based_affinity}"
    port                  = "${var.backend_http_port}"
    protocol              = "${var.backend_http_protocol}"
  }

  http_listener {
    name                           = "${var.appgateway_listener_name}"
    frontend_ip_configuration_name = "${var.appgateway_frontend_ip_configuration_name}"
    frontend_port_name             = "${var.appgateway_frontend_port_name}"
    protocol                       = "${var.http_listener_protocol}"
  }

  request_routing_rule {
    name                        = "${var.appgateway_request_routing_rule_name}"
    rule_type                   = "${var.request_routing_rule_type}"
    http_listener_name          = "${var.appgateway_listener_name}"
    backend_address_pool_name   = "${var.appgateway_backend_address_pool_name}"
    backend_http_settings_name  = "${var.appgateway_backend_http_setting_name}"
  }
}
