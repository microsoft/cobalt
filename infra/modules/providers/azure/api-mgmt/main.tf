module "azure-provider" {
    source = "../provider"
}

resource "random_id" "remotestate_account_name" {
  byte_length = 6
  keepers {
    sa_account_ref = 1
  }
}

resource "azurerm_resource_group" "apimgmt" {
  name     = "${var.resource_group_name == "" ? "${local.name}-cobalt-rg" : "${var.resource_group_name}"}"
  location = "${var.resource_group_location}"
  tags     = "${merge(map("Name", "${local.name}"), var.resource_tags)}"
}

resource "azurerm_api_management" "apimgmt" {
  name                = "${var.apimgmt_name == "" ? "api-${local.name}-cobalt-apimgmt" : "${var.apimgmt_name}"}"
  location            = "${azurerm_resource_group.apimgmt.location}"
  resource_group_name = "${azurerm_resource_group.apimgmt.name}"
  publisher_name      = "${var.apimgmt_pub_name}"
  publisher_email     = "${var.apimgmt_pub_email}"
  tags                = "${merge(map("Name", "${local.name}"), var.resource_tags)}"

  sku {
    name     = "${var.apimgmt_sku}"
    capacity = "${var.apimgmt_capacity}"
  }
}