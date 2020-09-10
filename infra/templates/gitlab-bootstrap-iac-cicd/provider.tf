provider "azurerm" {
  version = "=2.22"
  features {}
}

provider "azuread" {
  version = "=0.10.0"
}

provider "gitlab" {
  version = "=2.10.0"
}

provider "random" {
  version = "=2.2.1"
}

provider "tls" {
  version = "=2.1.1"
}
