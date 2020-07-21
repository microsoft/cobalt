terraform {
  backend "azurerm" {
    key = "terraform.tfstate"
  }
}

provider "azurerm" {
  version = "~> 2.9.0"
  features {}
}

