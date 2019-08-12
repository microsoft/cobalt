# Note to developers: This file shows some examples that you may
# want to use in order to configure this template. It is your
# responsibility to choose the values that make sense for your application.
#
# Note: These values will impact the names of resources. If your deployment
# fails due to a resource name colision, consider using different values for
# the `name` variable.

deployment_targets = [
  {
    app_name                 = "cobalt-backend-api-1",
    repository               = "",
    dockerfile               = "",
    image_name               = "appsvcsample/echo-server-1",
    image_release_tag_prefix = "release"
    auth_client_id           = ""
    }, {
    app_name                 = "cobalt-backend-api-2",
    repository               = "",
    dockerfile               = "",
    image_name               = "appsvcsample/echo-server-2",
    image_release_tag_prefix = "release"
    auth_client_id           = ""
  }
]

# Note: this is configured as such only to test IP Whitelists. This is a well
# known DNS address
resource_ip_whitelist   = ["1.1.1.1"]
ase_name                = "cobalt-static-ase"
name                    = "isolated-service"
ase_resource_group      = "cobalt-static-ase-rg"
ase_vnet_name           = "cobalt-static-ase-vnet"
resource_group_location = "eastus2"
