# Module Azure Application Gateway

Azure Application Gateway is a web traffic load balancer that enables you to manage traffic to your web applications. Traditional load balancers operate at the transport layer and route traffic based on source IP address and port, to a destination IP address and port. But with the Application Gateway you can be even more specific. For example, you can route traffic based on the incoming URL. So if `/images` is in the incoming URL, you can route traffic to a specific set of servers configured for images. If `/video` is in the URL, that traffic is routed to another pool optimized for videos. This type of routing is known as application layer load balancing. Azure Application Gateway can do URL-based routing and more.

More information for Azure Application Gateway can be found [here](https://azure.microsoft.com/en-us/services/application-gateway/)

A terraform module in Cobalt to provide Application Gateway with the following characteristics:

- Ability to specify resource group name in which the Application Gateway is deployed.
- Ability to specify resource group location in which the Application Gateway is deployed.
- Also gives ability to specify the following for Azure Application Gateway based on the requirements:
  - name : The name of the Application Gateway. Changing this forces a new resource to be created.
  - tags : A mapping of tags to assign to the resource.
  - SKU
    - name : The Name of the SKU to use for this Application Gateway. Possible values are Standard_Small, Standard_Medium, Standard_Large, Standard_v2, WAF_Medium, WAF_Large, and WAF_v2.
    - tier : The Tier of the SKU to use for this Application Gateway. Possible values are Standard, Standard_v2, WAF and WAF_v2.
    - capacity : The Capacity of the SKU to use for this Application Gateway - which must be between 1 and 10.
  - gateway_ip_configuration
    - name : The Name of this Gateway IP Configuration.
    - subnet_id : The ID of a Subnet.
  - frontend_port
    - name : The name of the Frontend Port.
    - port : The port used for this Frontend Port.
  - frontend_ip_configuration
    - name : The name of the Frontend IP Configuration.
    - public_ip_address_id : The ID of a Public IP Address which the Application Gateway should use.
  - backend_address_pool
    - name : The name of the Backend Address Pool.
  - backend_http_settings
    - name : The name of the Backend HTTP Settings Collection.
    - cookie_based_affinity : Is Cookie-Based Affinity enabled? Possible values are Enabled and Disabled.
    - port : The port which should be used for this Backend HTTP Settings Collection.
    - protocol : The Protocol which should be used. Possible values are Http and Https.
  - http_listener
    - name : The Name of the HTTP Listener.
    - frontend_ip_configuration_name : The Name of the Frontend IP Configuration used for this HTTP Listener.
    - frontend_port_name : The Name of the Frontend Port use for this HTTP Listener.
    - protocol : The Protocol to use for this HTTP Listener. Possible values are Http and Https.
  - request_routing_rule
    - name : The Name of this Request Routing Rule.
    - rule_type : The Type of Routing that should be used for this Rule. Possible values are Basic and PathBasedRouting.
    - http_listener_name : The Name of the HTTP Listener which should be used for this Routing Rule.
    - backend_address_pool_name : The Name of the Backend Address Pool which should be used for this Routing Rule. Cannot be set if redirect_configuration_name is set.
    - backend_http_settings_name : The Name of the Backend HTTP Settings Collection which should be used for this Routing Rule. Cannot be set if redirect_configuration_name is set.


Please click the [link](https://www.terraform.io/docs/providers/azurerm/r/application_gateway.html) to get additional details on settings in Terraform for Azure Application Gateway.

## Usage

```
variable "resource_group_name" {
  default = "cblt-rg"
}

variable "location" {
  default = "eastus"
}

resource "azurerm_resource_group" "appgateway" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
  tags     = "${var.resource_tags}"
}

resource "azurerm_application_gateway" "appgateway" {
  name                = "${var.appgateway_name}"
  resource_group_name = "${azurerm_resource_group.appgateway.name}"
  location            = "${azurerm_resource_group.appgateway.location}"
  tags                = "${var.resource_tags}"

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
    name                  = "${var.appgateway_frontend_ip_configuration_name}"
    public_ip_address_id  = "${var.appgateway_frontend_public_ip_address_id}"
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