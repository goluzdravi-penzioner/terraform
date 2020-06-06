resource "azurerm_virtual_network" "ak-core" {
  name                = var.cus_name
  address_space       = ["10.20.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group
}

resource "azurerm_subnet" "nodes" {
  name                 = "aks-pods"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.ak-core.name
  address_prefixes     = ["10.20.1.0/24"]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.AzureCosmosDB"]
}
