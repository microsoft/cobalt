# GENERAL
resource_group_location = "eastus"
name = "cobalt-az-simple"

# SERVICE PLAN
app_service_name = { 
    cobalt-backend-api = "DOCKER|msftcse/cobalt-azure-simple:0.1" 
}