module "logzio" {
  source          = "./logzio"
  logzio_listener = var.logzio_listener
  logzio_token    = var.logzio_token
  cluster_name    = var.cluster_name
  enabled         = var.logzio_enabled
}

module "api-gateway" {
  source               = "./api-gateway"
  namespace            = var.namespace
  cluster_name         = var.cluster_name
  app_name             = "api-gateway"
  docker_registry      = var.docker_registry
  image_tag            = var.api-gateway_image
  domain               = var.domain
  redis_host           = data.terraform_remote_state.infrastructure_state.outputs.redis_hostname
  redis_password       = data.terraform_remote_state.infrastructure_state.outputs.redis_password
  redis_ssl_port       = data.terraform_remote_state.infrastructure_state.outputs.redis_ssl_port
  redis_port           = data.terraform_remote_state.infrastructure_state.outputs.redis_port
  auth_client_secret   = random_string.auth_clients_secret.result
  db_address           = data.terraform_remote_state.infrastructure_state.outputs.mysql
  mysql_name           = data.terraform_remote_state.infrastructure_state.outputs.mysql_name
  db_pass              = data.terraform_remote_state.infrastructure_state.outputs.passwords.0["api-gateway"].result
  api-gateway-tls-cert = var.tls-cert
  api-gateway-tls-key  = var.tls-key
  data-gateway_key     = var.data-gateway_key
  connservice_key      = var.connservice_key
  mellariusv2_key      = var.mellariusv2_key
  mellarius_key        = var.mellarius_key
  userservice_key      = var.userservice_key
  external_cert        = var.external_cert
  cloud_env            = var.cloud_env
}

module "auth" {
  source                    = "./auth"
  namespace                 = var.namespace
  cluster_name              = var.cluster_name
  app_name                  = "auth-service"
  docker_registry           = var.docker_registry
  image_tag                 = var.auth-service_image
  domain                    = var.domain
  jwks_keystore_pass        = var.auth_service_jwks_keystore_pass
  jwks_keystore_path        = var.auth_service_jwks_keystore_path
  jwks_keystore_alias       = var.auth_service_jwks_keystore_alias
  auth_client_secret        = random_string.auth_clients_secret.result
  google_auth               = var.auth_service_google_auth
  google_client_id          = var.auth_service_google_client_id
  google_client_secret      = var.auth_service_google_client_secret
  google_recaptcha_site_key = var.google_recaptcha_site_key
  db_pass                   = data.terraform_remote_state.infrastructure_state.outputs.passwords.0["auth-service"].result
  db_address                = data.terraform_remote_state.infrastructure_state.outputs.mysql
  mysql_name                = data.terraform_remote_state.infrastructure_state.outputs.mysql_name
  auth-service-tls-cert     = var.tls-cert
  auth-service-tls-key      = var.tls-key
  external_cert             = var.external_cert
  cloud_env                 = var.cloud_env
  product_name              = var.product_name
}

module "coap-gateway" {
  source           = "./coap-gateway"
  namespace        = var.namespace
  cluster_name     = var.cluster_name
  app_name         = "coap-gateway"
  docker_registry  = var.docker_registry
  image_tag        = var.coap-gateway_image
  data_gateway_key = var.coapkey
  domain           = var.domain
}

module "core-ui" {
  source           = "./core-ui"
  namespace        = var.namespace
  cluster_name     = var.cluster_name
  app_name         = "core-ui"
  docker_registry  = var.docker_registry
  image_tag        = var.core-ui_image
  domain           = var.domain
  core-ui-tls-cert = var.tls-cert
  core-ui-tls-key  = var.tls-key
  external_cert    = var.external_cert
  enabled          = var.core-ui
  product_name     = var.product_name
  status_page      = var.status_page
  documentation_url= var.documentation_url
}

module "cron-service" {
  source                      = "./cron-service"
  namespace                   = var.namespace
  cluster_name                = var.cluster_name
  app_name                    = "cron-service"
  docker_registry             = var.docker_registry
  image_tag                   = var.cron-service_image
  domain                      = var.domain
  auth_client_secret          = random_string.auth_clients_secret.result
  db_pass                     = data.terraform_remote_state.infrastructure_state.outputs.passwords.0["cron-service"].result
  db_address                  = data.terraform_remote_state.infrastructure_state.outputs.mysql
  mysql_name                  = data.terraform_remote_state.infrastructure_state.outputs.mysql_name
  key_in_connectivityservice  = var.key_in_connectivityservice
  key_out_connectivityservice = var.key_out_connectivityservice
  cloud_env                   = var.cloud_env
}

module "data-gateway" {
  source                 = "./data-gateway"
  namespace              = var.namespace
  cluster_name           = var.cluster_name
  app_name               = "data-gateway"
  docker_registry        = var.docker_registry
  image_tag              = var.data-gateway_image
  domain                 = var.domain
  mongo_uri              = local.mongo_uri
  db_pass                = data.terraform_remote_state.infrastructure_state.outputs.passwords.0["data-gateway"].result
  db_address             = data.terraform_remote_state.infrastructure_state.outputs.mysql
  mysql_name             = data.terraform_remote_state.infrastructure_state.outputs.mysql_name
  data-gateway-tls-cert  = var.tls-cert
  data-gateway-tls-key   = var.tls-key
  mqttkey                = var.mqttkey
  coapkey                = var.coapkey
  apikey                 = var.apikey
  mellariuskey           = var.mellariuskey
  mellariusv2_key        = var.datagateway_mellariusv2_key
  connectivityservicekey = var.connectivityservicekey
  timerservicekey        = var.timerservicekey
  external_cert          = var.external_cert
  cloud_env              = var.cloud_env
}

module "integration-service" {
  source                         = "./integration-service"
  namespace                      = var.namespace
  cluster_name                   = var.cluster_name
  app_name                       = "integration-service"
  docker_registry                = var.docker_registry
  image_tag                      = var.integration-service_image
  domain                         = var.domain
  encryption_name_current        = var.connectivity_manager_encryption_name_current
  encryption_key_current         = var.connectivity_manager_encryption_key_current
  encryption_name_old            = var.connectivity_manager_encryption_name_old
  encryption_key_old             = var.connectivity_manager_encryption_key_old
  redis_host                     = data.terraform_remote_state.infrastructure_state.outputs.redis_hostname
  redis_password                 = data.terraform_remote_state.infrastructure_state.outputs.redis_password
  redis_ssl_port                 = data.terraform_remote_state.infrastructure_state.outputs.redis_ssl_port
  redis_port                     = data.terraform_remote_state.infrastructure_state.outputs.redis_port
  enabled                        = var.integration_service
  db_pass                        = data.terraform_remote_state.infrastructure_state.outputs.passwords.0["integration-service"].result
  db_address                     = data.terraform_remote_state.infrastructure_state.outputs.mysql
  mysql_name                     = data.terraform_remote_state.infrastructure_state.outputs.mysql_name
  cloud_env                      = var.cloud_env
  integration_types              = var.connectivity_manager_integration_types
  integration_loriot_key         = var.connectivity_manager_integration_loriot_key
  integration_swisscom_key       = var.connectivity_manager_integration_swisscom_key
  integration_ttn_key            = var.connectivity_manager_integration_ttn_key
  integration_loriot_enabled     = var.integration_loriot_enabled
  integration_swisscom_enabled   = var.integration_swisscom_enabled
  integration_ttn_enabled        = var.integration_ttn_enabled
  legacy_integration_loriot_id   = var.connectivity_manager_legacy_integration_loriot_id
  legacy_integration_swisscom_id = var.connectivity_manager_legacy_integration_swisscom_id
  legacy_integration_ttn_id      = var.connectivity_manager_legacy_integration_ttn_id
  apikey_in_data-gateway         = var.apikey_in_data-gateway
  apikey_in_apirouter            = var.apikey_in_apirouter
  apikey_in_mellariusv1          = var.apikey_in_mellariusv1
  apikey_in_mellariusv2          = var.apikey_in_mellariusv2
  apikey_in_cronservice          = var.apikey_out_cronservice
  apikey_out_mellariusv2         = var.apikey_out_mellariusv2
  apikey_out_cronservice         = var.apikey_out_cronservice
}

module "inventory-service" {
  source          = "./inventory-service"
  namespace       = var.namespace
  cluster_name    = var.cluster_name
  app_name        = "inventory-service"
  docker_registry = var.docker_registry
  image_tag       = var.inventory-service_image
  domain          = var.domain
  db_pass         = data.terraform_remote_state.infrastructure_state.outputs.passwords.0["inventory-service"].result
  db_address      = data.terraform_remote_state.infrastructure_state.outputs.mysql
  mysql_name      = data.terraform_remote_state.infrastructure_state.outputs.mysql_name
  enabled         = var.inventory_service
  cloud_env       = var.cloud_env
}

module "mellarius" {
  source                      = "./mellarius"
  namespace                   = var.namespace
  cluster_name                = var.cluster_name
  app_name                    = "mellarius"
  docker_registry             = var.docker_registry
  image_tag                   = var.mellarius_image
  domain                      = var.domain
  db_pass                     = data.terraform_remote_state.infrastructure_state.outputs.passwords.0["mellarius"].result
  db_address                  = data.terraform_remote_state.infrastructure_state.outputs.mysql
  mysql_name                  = data.terraform_remote_state.infrastructure_state.outputs.mysql_name
  mongo_uri                   = local.mongo_uri
  data-gateway_key            = var.mellariusv1_data-gateway_key
  google_recaptcha_secret_key = var.google_recaptcha_secret_key
  mellariusv2_key             = var.mellariusv1_mellariusv2_key
  connectivity-manager_key    = var.mellariusv1_connectivity-manager_key
  cloud_env                   = var.cloud_env
}

module "mellarius-v2" {
  source                               = "./mellarius-v2"
  namespace                            = var.namespace
  cluster_name                         = var.cluster_name
  app_name                             = "mellarius-v2"
  docker_registry                      = var.docker_registry
  image_tag                            = var.mellarius-v2_image
  domain                               = var.domain
  db_pass                              = data.terraform_remote_state.infrastructure_state.outputs.passwords.0["mellarius-v2"].result
  db_address                           = data.terraform_remote_state.infrastructure_state.outputs.mysql
  mysql_name                           = data.terraform_remote_state.infrastructure_state.outputs.mysql_name
  apikey_in_apirouter                  = var.mellariusv2_apikey_in_apirouter
  apikey_in_connectivityservice        = var.mellariusv2_apikey_in_connectivityservice
  apikey_in_data-gateway               = var.mellariusv2_apikey_in_data-gateway
  apikey_in_userservice                = var.mellariusv2_apikey_in_userservice
  apikey_in_cronservice                = var.mellariusv2_apikey_in_cronservice
  apikey_out_connectivityservice       = var.mellariusv2_apikey_out_connectivityservice
  apikey_out_data-gateway              = var.mellariusv2_apikey_out_data-gateway
  apikey_out_userservice               = var.mellariusv2_apikey_out_userservice
  apikey_out_repository_mail_templates = var.mellariusv2_apikey_out_repository_mail_templates
  apikey_out_mailgun                   = var.mellariusv2_apikey_out_mailgun
  integration_automatic_domains        = var.mellariusv2_integration_automatic_domains
  cloud_env                            = var.cloud_env
}

module "mqtt-broker" {
  source          = "./mqtt-broker"
  namespace       = var.namespace
  cluster_name    = var.cluster_name
  app_name        = "mqtt-broker"
  docker_registry = var.docker_registry
  image_tag       = var.mqtt-broker_image
  broker_password = base64encode(random_password.mqtt_broker_password.result)
  cloud_env       = var.cloud_env
}

module "mqtt-gateway" {
  source           = "./mqtt-gateway"
  namespace        = var.namespace
  cluster_name     = var.cluster_name
  app_name         = "mqtt-gateway"
  docker_registry  = var.docker_registry
  image_tag        = var.mqtt-gateway_image
  broker_password  = base64encode(random_password.mqtt_broker_password.result)
  data_gateway_key = var.mqttkey
  domain           = var.domain
}

module "platform" {
  source            = "./platform"
  namespace         = var.namespace
  cluster_name      = var.cluster_name
  app_name          = "platform"
  docker_registry   = var.docker_registry
  image_tag         = var.platform_image
  domain            = var.domain
  platform-tls-cert = var.tls-cert
  platform-tls-key  = var.tls-key
  external_cert     = var.external_cert
  product_name      = var.product_name
  status_page       = var.status_page
}

module "query-service" {
  source          = "./query-service"
  namespace       = var.namespace
  cluster_name    = var.cluster_name
  app_name        = "query-service"
  docker_registry = var.docker_registry
  image_tag       = var.query-service_image
  mongo_uri       = local.mongo_uri
  enabled         = var.query_service
}

module "scriptrunner" {
  source          = "./scriptrunner"
  namespace       = var.namespace
  cluster_name    = var.cluster_name
  app_name        = "scriptrunner"
  docker_registry = var.docker_registry
  image_tag       = var.scriptrunner_image
  domain          = var.domain
}

module "smapp-api" {
  source               = "./smapp-api"
  namespace            = var.namespace
  cluster_name         = var.cluster_name
  app_name             = "smapp-api"
  docker_registry      = var.docker_registry
  image_tag            = var.smapp-api_image
  cron_image_tag       = var.smapp-api-cron_image
  redis_host           = data.terraform_remote_state.infrastructure_state.outputs.redis_host_smapp
  redis_password       = data.terraform_remote_state.infrastructure_state.outputs.redis_password
  redis_port           = data.terraform_remote_state.infrastructure_state.outputs.redis_port
  redis_ssl_port       = data.terraform_remote_state.infrastructure_state.outputs.redis_ssl_port
  db_host              = data.terraform_remote_state.infrastructure_state.outputs.mysql
  db_pass              = data.terraform_remote_state.infrastructure_state.outputs.passwords.0["bi-module"].result
  environments_api_key = var.bi-modules_environments-api-key
  tls-cert             = var.tls-cert
  tls-key              = var.tls-key
  domain               = var.domain
  enabled              = var.bi-modules
  external_cert        = var.external_cert
  mysql_name           = data.terraform_remote_state.infrastructure_state.outputs.mysql_name
  cloud_env            = var.cloud_env
}

module "smapp-web" {
  source          = "./smapp-web"
  namespace       = var.namespace
  cluster_name    = var.cluster_name
  app_name        = "smapp-web"
  docker_registry = var.docker_registry
  image_tag       = var.smapp-web_image
  domain          = var.domain
  tls-cert        = var.tls-cert
  tls-key         = var.tls-key
  enabled         = var.bi-modules
  external_cert   = var.external_cert
}

module "smapp-signage" {
  source          = "./smapp-signage"
  namespace       = var.namespace
  cluster_name    = var.cluster_name
  app_name        = "smart-signage-app"
  docker_registry = var.docker_registry
  image_tag       = var.smart-signage-app_image
  domain          = var.domain
  tls-cert        = var.tls-cert
  tls-key         = var.tls-key
  enabled         = var.bi-modules
  external_cert   = var.external_cert
}

module "template-service" {
  source          = "./template-service"
  namespace       = var.namespace
  cluster_name    = var.cluster_name
  app_name        = "template-service"
  docker_registry = var.docker_registry
  image_tag       = var.template-service_image
  db_pass         = data.terraform_remote_state.infrastructure_state.outputs.passwords.0["template-service"].result
  db_address      = data.terraform_remote_state.infrastructure_state.outputs.mysql
  enabled         = var.template_service
  mysql_name      = data.terraform_remote_state.infrastructure_state.outputs.mysql_name
  cloud_env       = var.cloud_env
}

module "timer-service" {
  source          = "./timer-service"
  namespace       = var.namespace
  cluster_name    = var.cluster_name
  app_name        = "timer-service"
  docker_registry = var.docker_registry
  image_tag       = var.timer-service_image
  domain          = var.domain
}

module "user-service" {
  source                      = "./user-service"
  namespace                   = var.namespace
  cluster_name                = var.cluster_name
  app_name                    = "user-service"
  docker_registry             = var.docker_registry
  image_tag                   = var.user-service_image
  domain                      = var.domain
  auth_client_secret          = random_string.auth_clients_secret.result
  mgmt_email_address          = var.user_service_mgmt_email_address
  support_email_address       = var.user_service_support_email_address
  statuspage_url              = var.user_service_statuspage_url
  db_pass                     = data.terraform_remote_state.infrastructure_state.outputs.passwords.0["user-service"].result
  db_address                  = data.terraform_remote_state.infrastructure_state.outputs.mysql
  mysql_name                  = data.terraform_remote_state.infrastructure_state.outputs.mysql_name
  apikey_out_mellariusv2      = var.userservice_apikey_out_mellariusv2
  apikey_in_mellariusv2       = var.userservice_apikey_in_mellariusv2
  apikey_in_api-router        = var.userservice_apikey_in_api-router
  google_recaptcha_secret_key = var.google_recaptcha_secret_key
  cloud_env                   = var.cloud_env
}

### Set mongo uri to mongo-atlas for google deployments and to cosmosdb for azure deployments depending on the value of cloud_env variable ###
locals {
  mongo_uri = "${var.cloud_env == "google" ? var.mongo_atlas : element(data.terraform_remote_state.infrastructure_state.outputs.mongo, 0)}"
}

resource "random_integer" "refresh" {
  min = 11
  max = 1001
}
