variable "namespace" {}
variable "cluster_name" {}
variable "image_tag" {}
variable "app_name" {}
variable "docker_registry" {}
variable "domain" {}
variable "jwks_keystore_pass" {}
variable "jwks_keystore_path" {}
variable "jwks_keystore_alias" {}
variable "google_auth" {}
variable "google_client_id" {}
variable "google_client_secret" {}
variable "google_recaptcha_site_key" {}
variable "db_address" {}
variable "db_pass" {}
variable "db_user" {
  default = "auth-service"
}
variable "auth-service-tls-cert" {}
variable "auth-service-tls-key" {}
variable "external_cert" {}
variable "mysql_name" {}
variable "cloud_env" {
}
variable "auth_client_secret" {}
variable "product_name" {}
