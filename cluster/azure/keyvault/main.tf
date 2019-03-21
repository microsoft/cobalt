module "azure-provider" {
    source = "../provider"
}

data "terraform_remote_state" "cluster" {
   backend = "local" 
   config =
   {
     path = "../../terraform.tfstate"
   }
 }

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "keyvault" {
  name                = "${var.keyvault_name}"
  location            = "${data.terraform_remote_state.cluster.resource_group_location}"
  resource_group_name = "${data.terraform_remote_state.cluster.resource_group_name}"
  tenant_id           = "${data.azurerm_client_config.current.tenant_id}"

  sku {
    name = "${var.keyvault_sku}"
  }

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}
