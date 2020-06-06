resource "random_id" "azurerm_mysql_server_name_suffix" {
  byte_length = 8
}

resource "azurerm_mysql_server" "ak-core" {
  name                = "${var.cus_name}-mysql-${random_id.azurerm_mysql_server_name_suffix.dec}"
  location            = var.location
  resource_group_name = var.resource_group

  sku_name = var.mysql_sku_name

  storage_profile {
    storage_mb            = var.mysql_storage_size
    backup_retention_days = 7
    geo_redundant_backup  = "Disabled"
    auto_grow             = "Enabled"
  }

  administrator_login          = var.mysql_admin_login
  administrator_login_password = "${random_id.db_password_admin.hex}${random_id.db_password_admin.b64_std}"
  version                      = "5.7"
  ssl_enforcement              = "Disabled"
}

resource "azurerm_mysql_configuration" "mysql_config_wait_timeout" {
  name                = "wait_timeout"
  resource_group_name = var.resource_group
  server_name         = azurerm_mysql_server.ak-core.name
  value               = "660"
}

resource "azurerm_mysql_firewall_rule" "whitelist-belgrade" {
  depends_on          = [azurerm_mysql_server.ak-core]
  name                = "Belgrade-office"
  resource_group_name = var.resource_group
  server_name         = azurerm_mysql_server.ak-core.name
  start_ip_address    = "82.214.86.83"
  end_ip_address      = "82.214.86.83"
}

resource "azurerm_mysql_firewall_rule" "whitelist-zuerich" {
  depends_on          = [azurerm_mysql_server.ak-core]
  name                = "Zuerich-office"
  resource_group_name = var.resource_group
  server_name         = azurerm_mysql_server.ak-core.name
  start_ip_address    = "81.62.179.58"
  end_ip_address      = "81.62.179.58"
}

#TODO remove Terraform Cloud IP range after deployment
resource "azurerm_mysql_firewall_rule" "whitelist-terraform-cloud" {
  depends_on          = [azurerm_mysql_server.ak-core]
  name                = "Terraform-cloud"
  resource_group_name = var.resource_group
  server_name         = azurerm_mysql_server.ak-core.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}

resource "azurerm_mysql_virtual_network_rule" "mysqlvnetrule" {
  depends_on          = [azurerm_mysql_server.ak-core, azurerm_mysql_firewall_rule.whitelist-zuerich, azurerm_mysql_firewall_rule.whitelist-belgrade, azurerm_mysql_firewall_rule.whitelist-terraform-cloud, azurerm_subnet.nodes]
  name                = "mysql-vnet-rule"
  resource_group_name = var.resource_group
  server_name         = azurerm_mysql_server.ak-core.name
  subnet_id           = azurerm_subnet.nodes.id
}

resource "random_id" "db_password_admin" {
  byte_length = 8
}

resource "azurerm_mysql_database" "cera" {
  depends_on          = [azurerm_mysql_virtual_network_rule.mysqlvnetrule]
  name                = "cera"
  resource_group_name = var.resource_group
  server_name         = azurerm_mysql_server.ak-core.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_mysql_database" "auth" {
  depends_on          = [azurerm_mysql_virtual_network_rule.mysqlvnetrule]
  name                = "auth"
  resource_group_name = var.resource_group
  server_name         = azurerm_mysql_server.ak-core.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_mysql_database" "cron" {
  depends_on          = [azurerm_mysql_virtual_network_rule.mysqlvnetrule]
  name                = "cron"
  resource_group_name = var.resource_group
  server_name         = azurerm_mysql_server.ak-core.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_mysql_database" "bi-module" {
  depends_on          = [azurerm_mysql_virtual_network_rule.mysqlvnetrule]
  name                = "bi-module"
  resource_group_name = var.resource_group
  server_name         = azurerm_mysql_server.ak-core.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

### Users and Grants ###
provider "mysql" {
  endpoint = "${azurerm_mysql_server.ak-core.fqdn}:3306"
  username = "${azurerm_mysql_server.ak-core.administrator_login}@${azurerm_mysql_server.ak-core.name}"
  password = azurerm_mysql_server.ak-core.administrator_login_password
  tls      = true
}

resource "random_password" "password" {
  for_each         = toset(var.dbusers)
  length           = 12
  special          = true
  override_special = "_%@"
}

resource "mysql_user" "dbusers" {
  depends_on = [random_password.password, azurerm_mysql_virtual_network_rule.mysqlvnetrule]
  for_each   = toset(var.dbusers)
  #user       = "${each.value}@ak-core"
  user               = each.value
  host               = "%"
  tls_option         = "SSL"
  plaintext_password = random_password.password[each.value].result
}

resource "mysql_grant" "dbusers-services" {
  depends_on = [mysql_user.dbusers]

  for_each = toset(var.dbusers)
  #user       = "${each.value}@ak-core"
  user       = each.value
  host       = "%"
  database   = azurerm_mysql_database.cera.name
  privileges = ["SELECT", "UPDATE", "DELETE", "EXECUTE", "INSERT"]
}

resource "mysql_grant" "dbusers-cron-service" {
  depends_on = [mysql_user.dbusers]

  user       = "cron-service"
  host       = "%"
  database   = azurerm_mysql_database.cron.name
  privileges = ["SELECT", "UPDATE", "DELETE", "EXECUTE", "INSERT"]
}

resource "mysql_grant" "dbusers-auth-service" {
  depends_on = [mysql_user.dbusers]

  user       = "auth-service"
  host       = "%"
  database   = azurerm_mysql_database.auth.name
  privileges = ["SELECT", "UPDATE", "DELETE", "EXECUTE", "INSERT"]
}

resource "mysql_grant" "dbusers-bi-module" {
  depends_on = [mysql_user.dbusers]

  user       = "bi-module"
  host       = "%"
  database   = azurerm_mysql_database.bi-module.name
  privileges = ["SELECT", "UPDATE", "DELETE", "EXECUTE", "INSERT"]
}

variable "dbusers" {
  type    = list(string)
  default = ["api-gateway", "auth-service", "bi-module", "connectivity-service", "cron-service", "data-gateway", "inventory-service", "integration-service", "mellarius", "mellarius-v2", "template-service", "user-service"]
}
