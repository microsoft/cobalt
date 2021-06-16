provider "azurerm" {
  version = "=2.22"
  features {}
}

provider "azuread" {
  version = "=0.10.0"
}

provider "github" {
  version = "=4.10.0"
  token   = var.token
  owner   = var.owner
}

provider "random" {
  version = "=2.2.1"
}

provider "tls" {
  version = "=2.1.1"
}
