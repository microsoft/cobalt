# GENERAL
resource_group_location = "eastus"

deployment_targets = [{
  app_name                 = "cobalt-backend-api",
  image_name               = "appsvcsample/static-site",
  image_release_tag_prefix = "latest",
  auth_client_id           = ""
}]

