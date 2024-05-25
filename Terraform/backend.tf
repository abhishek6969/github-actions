terraform {
  backend "azurerm" {
    resource_group_name  = "remote-backend"
    storage_account_name = "lirookbackend"
    container_name       = "state-folder"
    key                  = "dev.terraform.tfstate"
  }
}
provider "azurerm" {
  features {}
}