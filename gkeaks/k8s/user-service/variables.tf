variable "namespace" {}
variable "cluster_name" {}
variable "image_tag" {}
variable "app_name" {}
variable "docker_registry" {}
variable "domain" {}
variable "auth_client_secret" {}
variable "mgmt_email_address" {}
variable "support_email_address" {}
variable "statuspage_url" {}
variable "db_address" {}
variable "db_pass" {}
variable "db_user" {
  default = "user-service"
}

variable "apikey_out_mellariusv2" {}
variable "apikey_in_mellariusv2" {}
variable "apikey_in_api-router" {}
variable "google_recaptcha_secret_key" {}
variable "mysql_name" {}
variable "cloud_env" {}