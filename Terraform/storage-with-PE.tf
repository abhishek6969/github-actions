resource "azurerm_storage_account" "testlirookstorage" {
  name                     = "testlirookstorage"
  resource_group_name      = azurerm_resource_group.testRG.name
  location                 = azurerm_resource_group.testRG.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "testcontainer" {
  name                  = "testcontainer"
  storage_account_name  = azurerm_storage_account.testlirookstorage.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "testblob" {
  name                   = "test.txt"
  storage_account_name   = azurerm_storage_account.testlirookstorage.name
  storage_container_name = azurerm_storage_container.testcontainer.name
  type                   = "Block"
  source                 = "test.txt"
}

resource "azurerm_private_endpoint" "pe-test" {
  name                = "pe-test"
  location            = azurerm_resource_group.testRG.location
  resource_group_name = azurerm_resource_group.testRG.name
  subnet_id           = azurerm_subnet.test-sb.id

  private_service_connection {
    name                           = "psc-test"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.testlirookstorage.id
    subresource_names              = ["blob"]
  }
}

output "private_endpoint_ip" {
  value = azurerm_private_endpoint.pe-test.private_service_connection[0].private_ip_address
}