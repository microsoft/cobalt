provider "azurerm" {
    version = "~>1.21.0"
}

terraform {
  required_version = "~> 0.11.11"
  backend "azurerm" {
  }
}

resource "azurerm_resource_group" "rg_core" {
  name = "core-usea-rg-test"
  location = "eastus"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "keyvault1" {
  name                = "core-usea-kv1-test"
  location            = "eastus"
  resource_group_name = "core-usea-rg-test"
  tenant_id           = "${data.azurerm_client_config.current.tenant_id}"
  depends_on          = ["azurerm_resource_group.rg_core"]

  sku {
    name = "standard"
  }
}
