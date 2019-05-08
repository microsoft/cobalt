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
    - subnet_id : The ID of the Subnet which the Application Gateway should be connected to.
    - private_ip_address : The Private IP Address to use for the Application Gateway.
    - public_ip_address_id : The ID of a Public IP Address which the Application Gateway should use.
  - backend_address_pool
    - name : The name of the Backend Address Pool.
    - ip_addresses : A list of IP Addresses which should be part of the Backend Address Pool.
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

### Module Definitions

- Service Plan Module        : infra/modules/providers/azure/service-plan
- Virtual Network Module     : https://github.com/Microsoft/bedrock/tree/master/cluster/azure/vnet
- Application Gateway Module : infra/modules/providers/azure/app-gateway

```
module "service_plan" {
  source                  = "github.com/Microsoft/cobalt/infra/modules/providers/azure/service-plan"
  resource_group_name     = "test-rg"
  resource_group_location = "eastus"
  service_plan_name       = "test-svcplan"
}

module "vnet" {
  source                  = "github.com/Microsoft/bedrock/cluster/azure/vnet"
  vnet_name               = "test-vnet"
  resource_group_name     = "${module.service_plan.resource_group_name}"
  resource_group_location = "${module.service_plan.resource_group_location}"
  subnet_names            = ["subnet1"]
}

module "appgateway" {
  source                                    = "github.com/Microsoft/cobalt/infra/modules/providers/azure/app-gateway"
  appgateway_name                           = "test-appgtwy"
  resource_group_name                       = "${module.service_plan.resource_group_name}"
  location                                  = "${module.service_plan.resource_group_location}"
  virtual_network_name                      = "${module.vnet.vnet_name}"
  subnet_name                               = "${module.vnet.subnet_names[0]}"
  appgateway_ipconfig_name                  = "test-ipconfig" 
  appgateway_frontend_port_name             = "test-frontend-port"
  appgateway_frontend_ip_configuration_name = "test-frontend-ipconfig"
  appgateway_backend_address_pool_name      = "test-backend-address-pool"
  appgateway_backend_http_setting_name      = "test-backend-http-setting"
  appgateway_listener_name                  = "test-appgateway-listener"
  appgateway_request_routing_rule_name      = "test-appgateway-request-routing-rule"
}
```

## Outputs

Once the deployments are completed successfully, the output for the current module will be in the format mentioned below:

```
Outputs:

appgateway_frontend_ip_configuration = [
    {
        id = /subscriptions/xxxxx239-caxx-xxbf-b2xx-xxxxxx08965a/resourceGroups/test-rg/providers/Microsoft.Network/applicationGateways/cblt-appgateway/frontendIPConfigurations/appgateway_frontend_ip_configuration,
        name = appgateway_frontend_ip_configuration,
        private_ip_address = xx.xx.1.xx,
        private_ip_address_allocation = Dynamic,
        public_ip_address_id = ,
        subnet_id = /subscriptions/xxxxx239-caxx-xxbf-b2xx-xxxxxx08965a/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/acctvnet/subnets/subnet1
    }
]
appgateway_ipconfig = [
    {
        id = /subscriptions/xxxxx239-caxx-xxbf-b2xx-xxxxxx08965a/resourceGroups/test-rg/providers/Microsoft.Network/applicationGateways/cblt-appgateway/gatewayIPConfigurations/appgateway_ipconfig,
        name = appgateway_ipconfig,
        subnet_id = /subscriptions/xxxxx239-caxx-xxbf-b2xx-xxxxxx08965a/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/acctvnet/subnets/subnet1
    }
]
appgateway_name = test-appgtwy
```
