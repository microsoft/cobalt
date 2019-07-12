# GENERAL
resource_group_location = "eastus"

app_service_name = {
    cobalt-backend-api = {
        image        = "appsvcsample/static-site:latest"
        ad_client_id = "ac92bf5b-ebf3-42f2-bb96-05fa7a8a6f30"
    }
}