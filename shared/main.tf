provider "azurerm" {
    version = "~>1.21.0"
}

terraform {
  required_version = "~> 0.11.11"
}

locals {
  location_suffixes = {
 eastasia = "asea",
 southeastasia = "assw",
 centralus = "usce",
 eastus = "usea",
 eastus2 = "use2",
 westus = "uswe",
 westus2 = "usw2",
 northcentralus = "usnc",
 southcentralus = "ussc",
 westcentralus = "uswc",
 northeurope = "euno",
 westeurope  = "euwe",
 japanwest = "jawe",
 japaneast = "jaea",
 brazilsouth = "brso",
 australiaeast = "auea",
 australiasoutheast = "ause",
 southindia  = "inso",
 centralindia  = "ince",
 westindia = "inwe",
 canadacentral = "cace",
 canadaeast = "caea",
 uksouth = "ukso",
 ukwest = "ukwe",
 koreacentral = "koce",
 koreasouth  = "koso",
 francecentral = "frce",
 francesouth = "frso",
 australiacentral = "auce",
 australiacentral2 = "auc2",
 southafricanorth= "sano",
 southafricawest = "sawe",
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
