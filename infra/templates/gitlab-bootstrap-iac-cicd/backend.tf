terraform {
  backend "azurerm" {
    key = "tf-bootstrap.tfstate"
  }
}
