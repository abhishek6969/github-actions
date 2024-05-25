resource "azurerm_virtual_network" "terraform-practice-vnet" {
  name                = "terraform-practice-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.terraform-practice.location
  resource_group_name = azurerm_resource_group.terraform-practice.name
}

resource "azurerm_subnet" "terraform-practice-vnet-sb01" {
  name                 = "terraform-practice-vnet-sb01"
  resource_group_name  = azurerm_resource_group.terraform-practice.name
  virtual_network_name = azurerm_virtual_network.terraform-practice-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
