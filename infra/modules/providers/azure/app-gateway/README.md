# Module Azure Application Gateway

Azure Application Gateway is a web traffic load balancer that enables you to manage traffic to your web applications. Traditional load balancers operate at the transport layer and route traffic based on source IP address and port, to a destination IP address and port. But with the Application Gateway you can be even more specific. For example, you can route traffic based on the incoming URL. So if `/images` is in the incoming URL, you can route traffic to a specific set of servers configured for images. If `/video` is in the URL, that traffic is routed to another pool optimized for videos. This type of routing is known as application layer load balancing. Azure Application Gateway can do URL-based routing and more.

A terraform module in Cobalt to provide Application Gateway with the following characteristics:

- Ability to specify resource group name in which the Application Gateway is deployed.
- Ability to specify resource group location in which the Application Gateway is deployed.
- Specify Application Gateway name, type and capacity of Application Gateway to deploy.


## Usage

```
variable "resource_group_name" {
  default = "cblt-apimgmt-rg"
}

variable "location" {
  default = "eastus"
}

resource "azurerm_resource_group" "apimgmt" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_application_gateway" "appgateway" {
  name                = "${var.appgateway_name}"
  resource_group_name = "${azurerm_resource_group.appgateway.name}"
  location            = "${azurerm_resource_group.appgateway.location}"

  sku {
    name     = "${var.appgateway_sku_name}"
    tier     = "${var.appgateway_tier}"
    capacity = "${var.appgateway_capacity}"
  }

  gateway_ip_configuration {
    name      = "${var.appgateway_ipconfig_name}"
    subnet_id = "${var.appgateway_ipconfig_subnet_id}"
  }

  frontend_port {
    name = "${var.appgateway_frontend_port_name}"
    port = 80
  }

  frontend_ip_configuration {
    name = "${var.appgateway_frontend_ip_configuration_name}"
    public_ip_address_id = "${var.appgateway_frontend_public_ip_address_id}"
  }

  backend_address_pool {
    name = "${var.appgateway_backend_address_pool_name}"
  }

  backend_http_settings {
    name                  = "${var.appgateway_backend_http_setting_name}"
    cookie_based_affinity = "${var.backend_http_cookie_based_affinity}"
    port                  = 80
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

```