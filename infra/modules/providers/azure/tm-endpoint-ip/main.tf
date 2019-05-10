data "azurerm_resource_group" "appgateway" {
  name                = "${var.resource_group_name}"
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.public_ip_name}"
  location            = "${data.azurerm_resource_group.appgateway.location}"
  resource_group_name = "${data.azurerm_resource_group.appgateway.name}"
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.public_ip_name}-dns"
  tags                = "${var.tags}"
}

resource "azurerm_traffic_manager_endpoint" "endpoint" {
  name                = "${var.endpoint_name}-ep"
  resource_group_name = "${data.azurerm_resource_group.appgateway.name}"
  profile_name        = "${var.traffic_manager_profile_name}"
  target              = "${var.endpoint_name}-dns"
  target_resource_id  = "${azurerm_public_ip.pip.id}"
  type                = "azureEndpoints"
  weight              = 1
}