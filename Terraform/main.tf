resource "azurerm_resource_group" "terraform-practice" {
  name     = "terraform-practice"
  location = "West Europe"
}

resource "azurerm_windows_virtual_machine" "terraform-practice-vm" {
  name                = "terraform-practice-vm"
  resource_group_name = azurerm_resource_group.terraform-practice.name
  location            = azurerm_resource_group.terraform-practice.location
  size                = "Standard_D4s_v3"
  admin_username      = "azureuser01"
  admin_password      = data.azurerm_key_vault_secret.VM-default-password.value
  network_interface_ids = [
    azurerm_network_interface.terraform-practice-vm-nic.id,
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