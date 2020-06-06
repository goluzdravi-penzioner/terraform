variable "namespace" {}
variable "cluster_name" {}
variable "image_tag" {}
variable "app_name" {}
variable "docker_registry" {}
variable "domain" {}
variable "auth_client_secret" {}
variable "db_address" {}
variable "db_pass" {}
variable "db_user" {
  default = "api-gateway"
}

variable "api-gateway-tls-cert" {}
variable "api-gateway-tls-key" {}

variable data-gateway_key {}
variable connservice_key {}
variable mellariusv2_key {}
variable mellarius_key {}
variable userservice_key {}
variable "external_cert" {}
variable "mysql_name" {}
variable "cloud_env" {}

variable "redis_host" {}
variable "redis_password" {}
variable "redis_ssl_port" {}
variable "redis_port" {}
