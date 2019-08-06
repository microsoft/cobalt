# Note to developers: This file shows some examples that you may
# want to use in order to configure this template. It is your
# responsibility to choose the values that make sense for your application.
#
# Note: These values will impact the names of resources. If your deployment
# fails due to a resource name colision, consider using different values for
# the `prefix` variable.

resource_group_location = "eastus"
prefix                  = "az-hello-world"
deployment_targets = [{
  app_name                 = "cobalt-backend-api",
  image_name               = "appsvcsample/static-site",
  image_release_tag_prefix = "latest",
  auth_client_id           = ""
}]

