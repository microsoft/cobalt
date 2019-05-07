# GENERAL
environment = "cobalt-azure-simple"
name = "cobalt-azure-simple"
resource_group_location = "eastus"
resource_group_name = "cobalt-azure-simple-rg"
cluster_name = "cobalt-azure-simple"
#service_principal_id = ""
#service_principal_secret = ""

# APP INSIGHTS
appinsights_name = "cobalt-azure-simple-ai"
apimgmt_logger_name = "cobalt-azure-simple-logger"
api_name = "cobalt-azure-simple"

# SERVICE PLAN
svcplan_tier = "Standard"
svcplan_size = "S1"
svcplan_kind = "Linux"
svcplan_capacity = "1"
service_plan_name = "cobalt-azure-simple-sp"
app_service_name = { cobaltazuresimpleappservice = "DOCKER|msftcse/cobalt-azure-simple:0.1" }

# VNET
vnet_name = "cobalt-azure-simple-vnet"
address_space = "10.0.0.0/16"
# subnet_names = "cobalt-azure-simple-subnet"
# subnet_prefixes = "10.10.1.0/24"
# dns_servers = ""
 subnet_service_endpoints = ["Microsoft.Web", "Microsoft.Web"]

# TRAFFIC-MANAGER-PROFILE
traffic_manager_profile_name = "cobalt-azure-simple-tm-p"
traffic_manager_dns_name = "cobalt"

# TRAFFIC-MANAGER-ENDPOINT
traffic_manager_profile_name = "cobalt-azure-simple-tm"
resource_location = "eastus"
public_ip_name = ""
endpoint_name = "cobalt"
ip_address_out_filename = "cobalt"
public_ip_name = "cobalt"

# API Manager
apimgmt_name = "cobalt"

# APP Gateway
appgateway_name = "cobalt"
appgateway_frontend_ip_configuration_name = "cobalt-azure-simple-appgateway_frontend_ip_configuration"
appgateway_frontend_port_name = "cobalt-azure-simple-appgateway_frontend_port"
appgateway_backend_http_setting_name = "cobalt"
appgateway_backend_address_pool_name = "cobalt-azure-simple-appgateway_backend_address_pool"
appgateway_capacity = "1"
appgateway_ipconfig_name = "cobalt-azure-simple-appgateway_ipconfig"
appgateway_listener_name = "cobalt-azure-simple-appgateway_listener"
appgateway_request_routing_rule_name = "cobalt-azure-simple-appgateway_request_routing_rule"
appgateway_tier = "Standard"
appgateway_sku_name = "Standard_Small"
backend_http_cookie_based_affinity = "Disabled"
backend_http_protocol = "Http"
http_listener_protocol = "Http"
request_routing_rule_type = "Basic"