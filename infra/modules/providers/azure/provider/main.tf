provider "azurerm" {
    version = "~>1.23.0"
}

terraform {
  required_version = "~> 0.11.13"
}

provider "null" {
    version = "~>2.0.0"
}

provider "azuread" {
  version = "~>0.1"
}
