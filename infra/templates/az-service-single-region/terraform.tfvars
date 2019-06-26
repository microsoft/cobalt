# GENERAL
resource_group_location = "eastus"
name = "cobalt-az-simple"
# SERVICE PLAN
app_service_name = {
    cobalt-backend-api = "msftcse/az-service-single-region:release" 
}
# ACR image deploy source
acr_build_git_source_url = "https://github.com/erikschlegel/echo-server.git"