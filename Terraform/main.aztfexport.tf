# resource "azurerm_windows_virtual_machine" "res-0" {
#   admin_password        = "Sunkale@14"
#   admin_username        = "adminuser"
#   location              = "northeurope"
#   name                  = "test-linux"
#   network_interface_ids = ["/subscriptions/bed9c8b2-bb60-492d-92a9-d1641fb7adf8/resourceGroups/test/providers/Microsoft.Network/networkInterfaces/test-linux103"]
#   resource_group_name   = "test"
#   size                  = "Standard_D4s_v3"
#   additional_capabilities {
#   }
#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }
#   source_image_reference {
#     offer     = "WindowsServer"
#     publisher = "MicrosoftWindowsServer"
#     sku       = "2022-datacenter-azure-edition"
#     version   = "latest"
#   }
# }
