# GENERAL
resource_group_location = "eastus"
name = "cobalt-azure-simple"

# SERVICE PLAN
app_service_name = { 
    cobalt-backend-api = "DOCKER|msftcse/cobalt-azure-simple:0.1" 
}

# VNET
subnet_service_endpoints = ["Microsoft.Web"]

# APP Gateway
appgateway_frontend_port_name = "http"
appgateway_backend_http_protocol = "Http"
appgateway_http_listener_protocol = "Http"