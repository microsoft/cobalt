
terraform {
  required_version = ">= 0.12"
}

provider "azurerm" {
  version = "~> 2.6.0"
  features {}
}