
output "mysql" {
  value = google_sql_database_instance.ak-core.private_ip_address
}

output "mysql_public_ip" {
  value = google_sql_database_instance.ak-core.public_ip_address
}

output "mysql_name" {
  value = google_sql_database_instance.ak-core.name
}

output "flyway_user" {
  value = google_sql_user.admin-user.name
}

output "flyway_pass" {
  value = google_sql_user.admin-user.password
}

output "mysql_flyway_user" {
  value = google_sql_user.admin-user.name
}

output "mysql_flyway_pass" {
  value = google_sql_user.admin-user.password
}

output "passwords" {
  value = random_password.password[*]
}

output "kube_host" {
  value = google_container_cluster.ak-core.endpoint
}

output "kube_config" {
  value = google_container_cluster.ak-core
}

output "client_certificate" {
  value = google_container_cluster.ak-core.master_auth.0.client_certificate
}

output "client_key" {
  value = google_container_cluster.ak-core.master_auth.0.client_key
}

output "cluster_ca_certificate" {
  value = google_container_cluster.ak-core.master_auth.0.cluster_ca_certificate
}

output "k8s_username" {
  value = google_container_cluster.ak-core.master_auth.0.username
}

output "k8s_password" {
  value = google_container_cluster.ak-core.master_auth.0.password
}

resource "random_integer" "refresh" {
  min = 153
  max = 1601
}

output "redis_hostname" {
  value = google_redis_instance.redis_cache.host
}

output "redis_host_smapp" {
  value = google_redis_instance.redis_cache_smapp.host
}

output "redis_password" {
  value = ""
}

output "redis_ssl_port" {
  value = 0
}

output "redis_port" {
  value = google_redis_instance.redis_cache.port
}
