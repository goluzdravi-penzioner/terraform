variable "namespace" {}
variable "cluster_name" {}
variable "image_tag" {}
variable "app_name" {}
variable "docker_registry" {}
variable "db_address" {}
variable "db_pass" {}
variable "db_user" {
  default = "template-service"
}
variable "enabled" {}
variable "mysql_name" {}
variable "cloud_env" {}