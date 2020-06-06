##### General Azure info ######################################################################################################
variable "location" {}
variable "cus_name" {}
variable "resource_group" {}
variable "azure_subscription_id" {}
variable "azure_client_id" {}
variable "azure_client_secret" {}
variable "azure_tenant_id" {}
variable "azure_partner_id" {
  default = "8d9727d8-e8b5-570c-a065-59dd2cebff54"
}

### AKS Nodepool vars ########################################################################################################
variable "default_nodepool_node_count" {}
variable "default_nodepool_max_count" {}
variable "default_nodepool_min_count" {}
variable "default_nodepool_vm_size" {}
variable "ssh_public_key" {}
variable "efk_nodepool_node_count" {}
variable "efk_nodepool_vm_size" {}

###########################################################################################################################

variable "dns_prefix" {}
variable cluster_name {}

### Log analytics ##########################################################################################################
variable log_analytics_workspace_name {
  default = "testLogAnalyticsWorkspaceName"
}
variable log_analytics_workspace_location {
  default = "switzerlandnorth"
}
variable log_analytics_workspace_sku {
  default = "PerGB2018"
}

###### Mysql server #######################################################################################################
variable "mysql_sku_name" {}
variable "mysql_storage_size" {}
variable "mysql_admin_login" {}
variable "mellarius-db-migrator_image" {}
variable "cron-service-db-migrator_image" {}
variable "auth-service-db-migrator_image" {}
variable "mongo-db-index-creator_image" {}

#### Moved from separate k8s repo ####
variable "domain" {}
variable "registry" {}
variable "namespace" {}
variable "redis_cache" {
  type = bool
}
variable "elk_monitoring" {
  type = bool
}

variable "data_rus" {
  default = 2000
}

variable "log_analytics" {
  type = bool
}
