variable "namespace" {}
variable "cluster_name" {}
variable "image_tag" {}
variable "app_name" {}
variable "docker_registry" {}
variable "domain" {}
variable "mongo_uri" {}
variable "db_address" {}
variable "db_pass" {}
variable "db_user" {
  default = "data-gateway"
}
variable "data-gateway-tls-cert" {}
variable "data-gateway-tls-key" {}
variable "mqttkey" {}
variable "coapkey" {}
variable "apikey" {}
variable "mellariuskey" {}
variable "mellariusv2_key" {}

variable "connectivityservicekey" {}
variable "timerservicekey" {}

variable "external_cert" {}
variable "mysql_name" {}
variable "cloud_env" {}




