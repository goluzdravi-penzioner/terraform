resource "azurerm_redis_cache" "ak-core" {
  count               = var.redis_cache ? 1 : 0
  name                = "ak-core-cache"
  location            = var.location
  resource_group_name = var.resource_group
  capacity            = 1
  family              = "C"
  sku_name            = "Standard"
}
