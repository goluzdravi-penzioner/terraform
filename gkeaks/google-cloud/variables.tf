### Google cloud credentials
variable "gcp_auth_type" {}
variable "gcp_auth_project_id" {}
variable "gcp_auth_private_key_id" {}
variable "gcp_auth_private_key" {
  type = string
} # Value for private_key in tfvars needs escape (\) for each \n in private key string from json config
variable "gcp_auth_client_email" {}
variable "gcp_auth_client_id" {}
variable "gcp_auth_auth_uri" {}
variable "gcp_auth_token_uri" {}
variable "gcp_auth_auth_provider_x509_cert_url" {}
variable "gcp_auth_client_x509_cert_url" {}
####
variable "registry" {}
variable "cluster-name" {}
variable "ip_whitelist" {
  type = map(string)
  default = {
    Zurich-office   = "81.62.179.58/32"
    Belgrade-office = "82.214.86.83/32"
    Jurij-office    = "87.116.178.219/32"
    all             = "0.0.0.0/0"
  }
}
variable "mellarius-db-migrator_image" {}
variable "cron-service-db-migrator_image" {}
variable "auth-service-db-migrator_image" {}
variable "sql_instance_type" {}
variable "region" {}
variable "location" {}
variable "project" {}
variable "gke_node_count" {}
variable "gke_min_node_count" {}
variable "gke_max_node_count" {}
variable "gke_node_type" {}
variable "namespace" {}
variable "domain" {}
