resource "azurerm_network_interface" "terraform-practice-vm-nic" {
  name                = "terraform-practice-vm-nic"
  location            = azurerm_resource_group.terraform-practice.location
  resource_group_name = azurerm_resource_group.terraform-practice.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.terraform-practice-vnet-sb01.id
    private_ip_address_allocation = "Dynamic"
  }
}