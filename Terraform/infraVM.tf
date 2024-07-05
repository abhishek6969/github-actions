data "azurerm_resource_group" "azureInfra" {
  name = "azureInfra"
}
data "azurerm_automation_account" "lirookAutomation" {
  name = "lirookAutomation"
  resource_group_name = data.azurerm_resource_group.azureInfra.name
  
}


data "azurerm_monitor_data_collection_rule" "example-dcr" {
  name                = "example-dcr"
  resource_group_name = data.azurerm_resource_group.azureInfra.name
}

data "azurerm_monitor_data_collection_rule" "dcr-CT" {
  name                = "dcr-CT"
  resource_group_name = data.azurerm_resource_group.azureInfra.name
}

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

resource "azurerm_network_interface" "test-nic2" {
  name                = "test-nic2"
  location            = azurerm_resource_group.testRG.location
  resource_group_name = azurerm_resource_group.testRG.name

  ip_configuration {
    public_ip_address_id          = azurerm_public_ip.test-ip.id
    name                          = "internal2"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.test-sb.id
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
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  identity {
    type = "SystemAssigned"
  }
  admin_password      = data.azurerm_key_vault_secret.VM-default-password.value
  network_interface_ids = [
    azurerm_network_interface.test-nic2.id
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

resource "azurerm_virtual_machine_extension" "Azure_Monitor_Windows_Agent" {
  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.test-vm.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true

  depends_on = [
    azurerm_monitor_data_collection_rule_association.VM-DCR-association,azurerm_monitor_data_collection_rule_association.VM-DCR-associationCT
  ]

}

resource "azurerm_virtual_machine_extension" "HybridWorkerExtension" {
  name                 = "HybridWorkerExtension"
  virtual_machine_id   = azurerm_windows_virtual_machine.test-vm.id
  publisher            = "Microsoft.Azure.Automation.HybridWorker"
  type                 = "HybridWorkerForWindows"
  type_handler_version = "1.1"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled = true
  settings = <<SETTINGS
  {
    "AutomationAccountURL": "https://0f22f0ea-0548-47bd-b83a-a65342e1a252.jrds.we.azure-automation.net/automationAccounts/0f22f0ea-0548-47bd-b83a-a65342e1a252"
  }
  SETTINGS

  protected_settings = <<PROTECTEDSETTINGS
  {}
  PROTECTEDSETTINGS



  depends_on = [
    azurerm_automation_hybrid_runbook_worker.example
  ]
}

# associate to a Data Collection Rule
resource "azurerm_monitor_data_collection_rule_association" "VM-DCR-association" {
  name                    = "${azurerm_windows_virtual_machine.test-vm.name}-DCR-association"
  target_resource_id      = azurerm_windows_virtual_machine.test-vm.id
  data_collection_rule_id = data.azurerm_monitor_data_collection_rule.example-dcr.id
  description             = "Association for VM and DCR"
}

resource "azurerm_virtual_machine_extension" "ChangeTracking-Windows" {
  name                       = "ChangeTracking-Windows"
  virtual_machine_id         = azurerm_windows_virtual_machine.test-vm.id
  publisher                  = "Microsoft.Azure.ChangeTrackingAndInventory"
  type                       = "ChangeTracking-Windows"
  type_handler_version       = "2.0"
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true
  depends_on = [
    azurerm_monitor_data_collection_rule_association.VM-DCR-association,azurerm_monitor_data_collection_rule_association.VM-DCR-associationCT
  ]
}

resource "azurerm_monitor_data_collection_rule_association" "VM-DCR-associationCT" {
  name                    = "${azurerm_windows_virtual_machine.test-vm.name}-DCR-association-CT"
  target_resource_id      = azurerm_windows_virtual_machine.test-vm.id
  data_collection_rule_id = data.azurerm_monitor_data_collection_rule.dcr-CT.id
  description             = "Association for VM and DCR for CT"
}
resource "random_uuid" "worker-uuid" {

}

resource "azurerm_automation_hybrid_runbook_worker" "example" {
  resource_group_name     = data.azurerm_resource_group.azureInfra.name
  automation_account_name = data.azurerm_automation_account.lirookAutomation.name
  worker_group_name       = "lirook-windows-workers"
  vm_resource_id          = azurerm_windows_virtual_machine.test-vm.id
  worker_id               = random_uuid.worker-uuid.result #unique uuid
  depends_on = [ random_uuid.worker-uuid ]
}