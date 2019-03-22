module "azure-provider" {
    source = "./azure/provider"
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

#Deploy keyvault
module "keyvault" { 
    source = "./azure/keyvault"
    resource_group_location = "${var.resource_group_location}"
    resource_group_name = "rg${local.suffix}"
    keyvault_name = "kv${local.suffix}"
}
