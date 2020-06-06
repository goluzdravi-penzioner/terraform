output "client_key" {
  value = azurerm_kubernetes_cluster.ak-core.kube_config.0.client_key
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.ak-core.kube_config.0.client_certificate
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.ak-core.kube_config.0.cluster_ca_certificate
}

output "cluster_username" {
  value = azurerm_kubernetes_cluster.ak-core.kube_config.0.username
}

output "cluster_password" {
  value = azurerm_kubernetes_cluster.ak-core.kube_config.0.password
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.ak-core.kube_config_raw
}

output "kube_host" {
  value = azurerm_kubernetes_cluster.ak-core.kube_config.0.host
}

output "mongo" {
  value = azurerm_cosmosdb_account.mongodb.connection_strings
}

output "mysql" {
  value = azurerm_mysql_server.ak-core.fqdn
}

output "mysql_name" {
  value = azurerm_mysql_server.ak-core.name
}
output "mysql_flyway_user" {
  value = azurerm_mysql_server.ak-core.administrator_login
}

output "mysql_flyway_pass" {
  value = azurerm_mysql_server.ak-core.administrator_login_password
}

output "passwords" {
  value = random_password.password[*]
}

output "redis_hostname" {
  value = "${var.redis_cache ? azurerm_redis_cache.ak-core.0.hostname : ""}"
}

output "redis_ssl_port" {
  value = "${var.redis_cache ? azurerm_redis_cache.ak-core.0.ssl_port : ""}"
}

output "redis_password" {
  value = "${var.redis_cache ? azurerm_redis_cache.ak-core.0.primary_access_key : ""}"
}
