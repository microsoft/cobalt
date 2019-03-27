module "azure-provider" {
    source = "./azure/provider"
}

locals {
  location_suffixes = {
    eastasia = "asea",
    southeastasia	= "assw",
    centralus	= "usce",
    eastus = "usea",
    eastus2	= "use2",
    westus = "uswe",
    westus2	= "usw2",
    northcentralus = "usnc",
    southcentralus = "ussc",
    westcentralus	= "uswc",
    northeurope	= "euno",
    westeurope	= "euwe",
    japanwest	= "jawe",
    japaneast	= "jaea",
    brazilsouth	= "brso",
    australiaeast	= "auea",
    australiasoutheast = "ause",
    southindia	= "inso",
    centralindia	= "ince",
    westindia	= "inwe",
    canadacentral	= "cace",
    canadaeast = "caea",
    uksouth	= "ukso",
    ukwest = "ukwe",
    koreacentral = "koce",
    koreasouth	= "koso",
    francecentral	= "frce",
    francesouth	= "frso",
    australiacentral = "auce",
    australiacentral2	= "auc2",
    southafricanorth= "sano",
    southafricawest	= "sawe",
  }
  location_suffix = "${local.location_suffixes[var.location]}"
  suffix = "${var.app_name}-${var.env}-${local.location_suffix}-${var.org}"
}

resource "azurerm_resource_group" "rg_core" {
  name = "rg-${local.suffix}"
  location = "${var.location}"
}