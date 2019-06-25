# GENERAL
resource_group_location = "eastus2"
name                    = "isolated-service"

# SERVICE PLAN
app_service_name = {
  cobalt-backend-api-1 = "appsvcsample/static-site:latest"
  cobalt-backend-api-2 = "appsvcsample/static-site:latest"
}
