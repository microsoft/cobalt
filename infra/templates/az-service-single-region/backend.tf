terraform {
  backend "azurerm" {
    key = "terraform.tfstate"
  }
}

provider "azurerm" {
  version = "~> 2.6.0"
  features {}
}

