# Note to developers: This file shows some examples that you may
# want to use in order to configure this template. It is your
# responsibility to choose the values that make sense for your application.
#
# Note: These values will impact the names of resources. If your deployment
# fails due to a resource name colision, consider using different values for
# the `name` variable.

resource_group_location = "eastus"
name = "az-simple"
deployment_targets = [{
    app_name                 = "cobalt-backend-api",
    image_name               = "msftcse/az-service-single-region",
    image_release_tag_prefix = "release",
    auth_client_id           = ""
}]
acr_build_git_source_url = "https://github.com/erikschlegel/echo-server.git"
