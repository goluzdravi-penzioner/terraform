variable "namespace" {}
variable "cluster_name" {}
variable "image_tag" {}
variable "cron_image_tag" {}
variable "app_name" {}
variable "docker_registry" {}
variable "domain" {}
variable "redis_host" {}
variable "redis_password" {}
variable "redis_ssl_port" {}
variable "redis_port" {}
variable "db_host" {}
variable "db_pass" {}
variable "db_name" {
  default = "bi-module"
}
variable "db_user" {
  default = "bi-module"
}
variable "environments_api_key" {}
variable "enabled" {}
variable "tls-cert" {}
variable "tls-key" {}
variable "external_cert" {}
variable "mysql_name" {}
variable "cloud_env" {}
