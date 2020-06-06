variable "namespace" {}
variable "cluster_name" {}
variable "image_tag" {}
variable "app_name" {}
variable "docker_registry" {}
variable "domain" {}
variable encryption_name_current {}
variable encryption_key_current {}
variable encryption_name_old {}
variable encryption_key_old {}
variable "db_address" {}
variable "db_pass" {}
variable "db_user" {
  default = "integration-service"
}
variable "enabled" {}

variable "mysql_name" {}
variable "cloud_env" {}

variable "redis_host" {}
variable "redis_password" {}
variable "redis_ssl_port" {}
variable "redis_port" {}

variable "integration_types" {}
variable integration_loriot_key {}
variable integration_swisscom_key {}
variable integration_ttn_key {}
variable legacy_integration_loriot_id {}
variable legacy_integration_swisscom_id {}
variable legacy_integration_ttn_id {}
variable "integration_loriot_enabled" {}
variable "integration_swisscom_enabled" {}
variable "integration_ttn_enabled" {}
variable "apikey_in_data-gateway" {}
variable "apikey_in_apirouter" {}
variable "apikey_in_mellariusv1" {}
variable "apikey_in_mellariusv2" {}
variable "apikey_in_cronservice" {}
variable "apikey_out_mellariusv2" {}
variable "apikey_out_cronservice" {}