# Note to developers: This file shows some examples that you may
# want to use in order to configure this template. It is your
# responsibility to choose the values that make sense for your application.
#
# Note: These values will impact the names of resources. If your deployment
# fails due to a resource name collision, consider using different values for
# the `name` variable or increasing the value for `randomization_level`.

resource_group_location = "eastus2"
name                    = "isolated-service"
randomization_level     = 8

# Targets that will be configured to also setup AuthN with Easy Auth
authn_deployment_targets = [
  {
    app_name                 = "co-frontend-api-1",
    image_name               = "appsvcsample/echo-server-1",
    image_release_tag_prefix = "release"
  }
]

# Targets that will not have any AuthN configured
unauthn_deployment_targets = [
  {
    app_name                 = "co-backend-api-1",
    image_name               = "appsvcsample/echo-server-2",
    image_release_tag_prefix = "release"
  }
]

# Note: this is configured as such only to test IP Whitelists. This is a well
# known DNS address
ase_name              = "co-static-ase"
ase_resource_group    = "co-static-ase-rg"
ase_vnet_name         = "co-static-ase-vnet"
resource_ip_whitelist = []
