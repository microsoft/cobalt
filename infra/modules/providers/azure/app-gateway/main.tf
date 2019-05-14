data "azurerm_resource_group" "appgateway" {
  name = "${var.resource_group_name}"
}

data "azurerm_virtual_network" "appgateway" {
  name                = "${var.virtual_network_name}"
  resource_group_name = "${data.azurerm_resource_group.appgateway.name}"
}

data "azurerm_subnet" "appgateway" {
  name                 = "${var.subnet_name}"
  resource_group_name  = "${data.azurerm_resource_group.appgateway.name}"
  virtual_network_name = "${data.azurerm_virtual_network.appgateway.name}"
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
    public_ip_address_id  = "${var.public_pip_id}"
  }

  backend_address_pool {
    name                  = "${var.appgateway_backend_address_pool_name}"
    fqdns                 = ["${var.backendpool_fqdns}"]
  }

  backend_http_settings {
    name                  = "${var.appgateway_backend_http_setting_name}"
    cookie_based_affinity = "${var.backend_http_cookie_based_affinity}"
    port                  = "${var.backend_http_port}"
    protocol              = "${var.backend_http_protocol}"
    probe_name            = "probe-1"
    request_timeout       = 1
    pick_host_name_from_backend_address = true
  }

  # TODO This is locked into a single api endpoint... We'll need to eventually support multiple endpoints
  # but the count property is only supported at the resource level. 
  probe {
    name                = "probe-1"
    protocol            = "${var.backend_http_protocol}"
    path                = "/"
    host                = "${var.backendpool_fqdns[0]}"
    interval            = "30"
    timeout             = "30"
    unhealthy_threshold = "3"
  }

  http_listener {
    name                           = "${var.appgateway_listener_name}"
    frontend_ip_configuration_name = "${var.appgateway_frontend_ip_configuration_name}"
    frontend_port_name             = "${var.appgateway_frontend_port_name}"
    protocol                       = "${var.http_listener_protocol}"
  }

  waf_configuration {
    enabled          = "true"
    firewall_mode    = "${var.appgateway_waf_config_firewall_mode}"
    rule_set_type    = "OWASP"
    rule_set_version = "3.0"
  }

  request_routing_rule {
    name                        = "${var.appgateway_request_routing_rule_name}"
    http_listener_name          = "${var.appgateway_listener_name}"
    rule_type                   = "${var.request_routing_rule_type}"
    backend_address_pool_name   = "${var.appgateway_backend_address_pool_name}"
    backend_http_settings_name  = "${var.appgateway_backend_http_setting_name}"
  }
}
