

resource "azurerm_resource_group" "testRG" {
  name     = "testRG"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test-vnet" {
  name                = "test-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.testRG.location
  resource_group_name = azurerm_resource_group.testRG.name
}

resource "azurerm_subnet" "test-sb" {
  name                 = "test-sb"
  resource_group_name  = azurerm_resource_group.testRG.name
  virtual_network_name = azurerm_virtual_network.test-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "test-nic" {
  name                = "test-nic"
  location            = azurerm_resource_group.testRG.location
  resource_group_name = azurerm_resource_group.testRG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test-sb.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "test-nic2" {
  name                = "test-nic2"
  location            = azurerm_resource_group.testRG.location
  resource_group_name = azurerm_resource_group.testRG.name

  ip_configuration {
    public_ip_address_id = azurerm_public_ip.test-ip.id
    name = "internal2"
    private_ip_address_allocation = "static"
  }
}

resource "azurerm_public_ip" "test-ip" {
  name                = "test-ip"
  resource_group_name = azurerm_resource_group.testRG.name
  location            = azurerm_resource_group.testRG.location
  allocation_method   = "Static"
}

resource "azurerm_windows_virtual_machine" "test-vm" {
  name                = "test-vm"
  resource_group_name = azurerm_resource_group.testRG.name
  location            = azurerm_resource_group.testRG.location
  size                = "Standard_D4s_v3"
  admin_username      = "adminuser"
  admin_password      = data.azurerm_key_vault_secret.VM-default-password.value
  network_interface_ids = [
    azurerm_network_interface.test-nic.id,azurerm_network_interface.test-nic2.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}