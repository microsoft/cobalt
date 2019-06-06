# GENERAL
resource_group_location = "eastus"

# SERVICE PLAN
app_service_name = { 
    cobalt-backend-api = "DOCKER|appsvcsample/static-site:latest" 
}