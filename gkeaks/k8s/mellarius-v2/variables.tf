variable "namespace" {}
variable "cluster_name" {}
variable "image_tag" {}
variable "app_name" {}
variable "docker_registry" {}
variable "domain" {}
variable "db_address" {}
variable "db_pass" {}
variable "db_user" {
  default = "mellarius-v2"
}
variable "apikey_in_apirouter" {}
variable "apikey_in_connectivityservice" {}
variable "apikey_in_data-gateway" {}
variable "apikey_in_userservice" {}
variable "apikey_in_cronservice" {}
variable "apikey_out_connectivityservice" {}
variable "apikey_out_data-gateway" {}
variable "apikey_out_userservice" {}
variable "apikey_out_repository_mail_templates" {}
variable "apikey_out_mailgun" {}

variable "integration_automatic_domains" {
  #type = list(string) 
}
variable "cloud_env" {}
variable "mysql_name" {}



