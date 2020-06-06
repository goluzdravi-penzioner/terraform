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
  default = "cron-service"
}

variable "key_in_connectivityservice" {}
variable "key_out_connectivityservice" {}

variable "mysql_name" {}
variable "cloud_env" {}


