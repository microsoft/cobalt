# GENERAL
resource_group_location = "eastus"
name = "cobalt-az-simple"
# SERVICE PLAN
deployment_targets = [{
    app_name                 = "cobalt-backend-api",
    image_name               = "msftcse/az-service-single-region",
    image_release_tag_prefix = "release",
    auth_client_id           = ""
}]
# ACR image deploy source
acr_build_git_source_url = "https://github.com/erikschlegel/echo-server.git"
