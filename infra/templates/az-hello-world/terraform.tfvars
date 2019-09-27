# Note to developers: This file shows some examples that you may
# want to use in order to configure this template. It is your
# responsibility to choose the values that make sense for your application.
#
# Note: These values will impact the names of resources. If your deployment
# fails due to a resource name collision, consider using different values for
# the `name` variable or increasing the value for `randomization_level`.

resource_group_location = "eastus"
name                    = "az-hello-world"
randomization_level     = 8

deployment_targets = [{
  app_name                 = "cobalt-backend-api",
  image_name               = "appsvcsample/static-site",
  image_release_tag_prefix = "latest"
}]
