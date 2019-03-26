provider "azurerm" {
    version = "~>1.21.0"
}

terraform {
  required_version = "~> 0.11.11"
}

locals {
  location_suffixes = {
    centralus = "cus"
    eastus = "eus"
    eastus2 = "eus2"
    westus = "wus"
    northcentralus = "ncus"
    southcentralus = "scus"
    westcentralus = "wcus"
    westus2 = "wus2"
  }

  location_suffix = "${local.location_suffixes[var.resource_group_location]}"
  suffix = "-infra-${var.env}-${local.location_suffix}-${var.org}"
}

resource "azurerm_resource_group" "rg_core" {
  name = "rg${local.suffix}"
  location = "${var.resource_group_location}"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "keyvault" {
  name                = "kv${local.suffix}"
  location            = "${var.resource_group_location}"
  resource_group_name = "rg${local.suffix}"
  tenant_id           = "${data.azurerm_client_config.current.tenant_id}"
  depends_on          = ["azurerm_resource_group.rg_core"]

  sku {
    name = "${var.keyvault_sku}"
  }

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}
