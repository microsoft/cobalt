resource "azuread_application" "auth" {
  count                      = length(var.ad_app_config)
  name                       = var.ad_app_config[count.index].app_name
  available_to_other_tenants = var.available_to_other_tenants
  oauth2_allow_implicit_flow = var.oauth2_allow_implicit_flow
  type                       = var.app_type
  reply_urls                 = var.ad_app_config[count.index].reply_urls

  required_resource_access {
    resource_app_id = var.resource_app_id

    resource_access {
      id   = var.resource_role_id
      type = var.resource_access_type
    }
  }
}

# what the resource outputs is not always the same as what data outputs
# object ids ----> list ---> data resource ---> reply urls w/ name + appid ----> azurecli
data "azuread_application" "auth" {
  count     = length(var.ad_app_config)
  object_id = azuread_application.auth[count.index].object_id
}