terraform {
  backend "azurerm" {
    key = "dev.terraform.tfstate"
  }
}
