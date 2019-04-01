provider "azurerm" {
    version = "~>1.21.0"
}

terraform {
  required_version = "~> 0.11.11"
}

locals {
  location_suffixes = {
    eastasia           = "asea",
    southeastasia      = "assw",
    centralus          = "usce",
    eastus             = "usea",
    eastus2            = "use2",
    westus             = "uswe",
    westus2            = "usw2",
    northcentralus     = "usnc",
    southcentralus     = "ussc",
    westcentralus      = "uswc",
    northeurope        = "euno",
    westeurope         = "euwe",
    japanwest          = "jawe",
    japaneast          = "jaea",
    brazilsouth        = "brso",
    australiaeast      = "auea",
    australiasoutheast = "ause",
    southindia         = "inso",
    centralindia       = "ince",
    westindia          = "inwe",
    canadacentral      = "cace",
    canadaeast         = "caea",
    uksouth            = "ukso",
    ukwest             = "ukwe",
    koreacentral       = "koce",
    koreasouth         = "koso",
    francecentral      = "frce",
    francesouth        = "frso",
    australiacentral   = "auce",
    australiacentral2  = "auc2",
    southafricanorth   = "sano",
    southafricawest    = "sawe",
  }

  location_suffix = "${local.location_suffixes[var.location]}"
}

resource "azurerm_resource_group" "rg_core" {
  name     = "core-${local.location_suffix}-rg-${var.company}"
  location = "${var.location}"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "keyvault" {
  name                = "core-${local.location_suffix}-kv-${var.company}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg_core.name}"
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

resource "azurerm_virtual_network" "vnet" {
  name                 = "core-${local.location_suffix}-vnet-${var.company}"
  address_space        = ["10.0.0.0/16"]
  location             = "${azurerm_resource_group.rg_core.location}"
  resource_group_name  = "${azurerm_resource_group.rg_core.name}"
}

resource "azurerm_subnet" "subnet" {
  name                 = "core-${local.location_suffix}-subnet-${var.company}"
  resource_group_name  = "${azurerm_resource_group.rg_core.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.0.1.0/24"
}
