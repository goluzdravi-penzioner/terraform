variable "namespace" {}
variable "cluster_name" {}
variable "image_tag" {}
variable "app_name" {}
variable "docker_registry" {}
variable "domain" {}
variable "db_address" {}
variable "db_pass" {}
variable "db_user" {
  default = "mellarius"
}
variable "data-gateway_key" {}
variable "connectivity-manager_key" {}
variable "google_recaptcha_secret_key" {}
variable "mellariusv2_key" {}

variable "mysql_name" {}
variable "cloud_env" {}
variable "mongo_uri" {}


