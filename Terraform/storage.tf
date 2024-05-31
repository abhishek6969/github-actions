resource "azurerm_storage_account" "testlirookstorage" {
  name                     = "testlirookstorage"
  resource_group_name      = azurerm_resource_group.testRG.name
  location                 = azurerm_resource_group.testRG.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.test-sb.id]
  }
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