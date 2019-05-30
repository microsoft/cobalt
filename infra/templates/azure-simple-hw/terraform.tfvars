# GENERAL
resource_group_location = "eastus"
name = "cobalt-az-hw"

# SERVICE PLAN
app_service_name = { 
    cobalt-backend-api = "DOCKER|msftcse/cobalt-azure-hw:0.1" 
}