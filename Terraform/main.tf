resource "azurerm_resource_group" "test" {
  name     = "test"
  location = "West Europe"
}

output "RG" {
  value = azurerm_resource_group.test.name
}