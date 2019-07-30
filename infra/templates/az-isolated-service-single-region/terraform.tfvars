# GENERAL
resource_group_location = "eastus2"
name                    = "isolated-service"

deployment_targets = [
{
    app_name = "cobalt-backend-api-1",
    repository = "",
    dockerfile = "",
    image_name = "appsvcsample/echo-server-1",
    image_release_tag_prefix = "release"
    auth_client_id = ""
}
]
