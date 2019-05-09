# GENERAL
resource_group_location = "eastus"
resource_group_name = "cobalt-azure-simple-rg"
name = "cobalt-azure-simple"

# SERVICE PLAN
app_service_name = { backendapi = "DOCKER|msftcse/cobalt-azure-simple:0.1" }

# VNET
subnet_service_endpoints = ["Microsoft.Web", "Microsoft.Web"]

# APP Gateway
appgateway_frontend_port_name = "http"
backend_http_protocol = "Http"
http_listener_protocol = "Http"