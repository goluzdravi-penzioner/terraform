variable "cluster_name" {}
variable "domain" {}
variable "namespace" {}
variable "google_recaptcha_site_key" {}
variable "google_recaptcha_secret_key" {}
variable "docker_registry" {}

variable "logzio_enabled" {}
variable "logzio_listener" {}
variable "logzio_token" {}

variable "api-gateway_image" {}
variable "auth-service_image" {}
variable "auth-service-db-migrator_image" {}
variable "connectivity-manager_image" {}
variable "data-gateway_image" {}
variable "coap-gateway_image" {}
variable "core-ui_image" {}
variable "cron-service_image" {}
variable "cron-service-db-migrator_image" {}
variable "integration-service_image" {}
variable "inventory-service_image" {}
variable "mellarius_image" {}
variable "mellarius-db-migrator_image" {}
variable "mellarius-v2_image" {}
variable "mqtt-broker_image" {}
variable "mqtt-gateway_image" {}
variable "platform_image" {}
variable "query-service_image" {}
variable "scriptrunner_image" {}
variable "smapp-api_image" {}
variable "smapp-api-cron_image" {}
variable "smapp-api-db-migrator_image" {}
variable "smart-signage-app_image" {}
variable "smapp-web_image" {}
variable "template-service_image" {}
variable "timer-service_image" {}
variable "user-service_image" {}

variable "auth_service_jwks_keystore_pass" {}
variable "auth_service_jwks_keystore_path" {
  default = "jwt/auth-service.jks"
}
variable "auth_service_jwks_keystore_alias" {
  default = "auth-service-jwt"
}
variable "additional_login_redirect_urls" {
  default = ""
}

variable "auth_service_google_auth" {}
variable "auth_service_google_client_id" {}
variable "auth_service_google_client_secret" {}

variable connectivity_manager_integration_types {}
variable connectivity_manager_integration_loriot_key {}
variable connectivity_manager_integration_swisscom_key {}
variable connectivity_manager_integration_ttn_key {}
variable connectivity_manager_legacy_integration_loriot_id {}
variable connectivity_manager_legacy_integration_swisscom_id {}
variable connectivity_manager_legacy_integration_ttn_id {}
variable connectivity_manager_encryption_name_current {}
variable connectivity_manager_encryption_name_old {}
variable connectivity_manager_encryption_key_current {}
variable connectivity_manager_encryption_key_old {}

variable data-gateway_key {}
variable connservice_key {}
variable mellariusv2_key {}
variable mellarius_key {}
variable userservice_key {}

variable "integration_loriot_enabled" {}
variable "integration_swisscom_enabled" {}
variable "integration_ttn_enabled" {}

variable "apikey_in_data-gateway" {}
variable "apikey_in_apirouter" {}
variable "apikey_in_mellariusv1" {}
variable "apikey_in_mellariusv2" {}
variable "apikey_in_cronservice" {}
variable "apikey_out_mellariusv2" {}
variable "apikey_out_cronservice" {}

variable user_service_mgmt_email_address {
  default = "ask@akenza.com"
}

variable user_service_support_email_address {
  default = "ask@akenza.com"
}

variable user_service_statuspage_url {
  default = "https://status.core.akenza.io"
}

variable "infrastructure_workspace_name" {}

variable "efk" {
  type = bool
}

variable "ext_dns" {
  type = bool
}

variable "cert_manager" {
  type = bool
}
variable "cloudflare_apikey" {}

variable "jaeger" {
  type = bool
}

variable "prometheus" {
  type = bool
}

variable "keycloak" {
  type = bool
}

variable tls-cert {}
variable tls-key {}
variable "external_cert" {
  type = bool
}

variable "integration_service" {
  type = bool
}
variable "inventory_service" {
  type = bool
}
variable "query_service" {
  type = bool
}
variable "template_service" {
  type = bool
}
variable "core-ui" {
  type = bool
}
variable "bi-modules" {
  type = bool
}

variable "key_in_connectivityservice" {}
variable "key_out_connectivityservice" {}
#data gateway
variable "mqttkey" {}
variable "coapkey" {}
variable "apikey" {}
variable "mellariuskey" {}
variable "datagateway_mellariusv2_key" {}
variable "connectivityservicekey" {}
variable "timerservicekey" {}

variable "mellariusv2_apikey_in_apirouter" {}
variable "mellariusv2_apikey_in_connectivityservice" {}
variable "mellariusv2_apikey_in_data-gateway" {}
variable "mellariusv2_apikey_in_userservice" {}
variable "mellariusv2_apikey_in_cronservice" {}
variable "mellariusv2_apikey_out_connectivityservice" {}
variable "mellariusv2_apikey_out_data-gateway" {}
variable "mellariusv2_apikey_out_userservice" {}
variable "mellariusv2_apikey_out_repository_mail_templates" {}
variable "mellariusv2_apikey_out_mailgun" {}

variable "mellariusv1_data-gateway_key" {}
variable "mellariusv1_connectivity-manager_key" {}
variable "mellariusv1_mellariusv2_key" {}

variable "userservice_apikey_out_mellariusv2" {}
variable "userservice_apikey_in_mellariusv2" {}
variable "userservice_apikey_in_api-router" {}

variable "mellariusv2_integration_automatic_domains" {
  #type = list(string) 
}

variable "mongo_atlas" {}
variable "cloud_env" {}

resource "random_password" "mqtt_broker_password" {
  length           = 32
  special          = true
  override_special = "_%@"
}

variable "bi-modules_environments-api-key" {}
variable "product_name" {
  default = "Akenza Core"
}
variable "status_page" {
  default = "https://status.core.akenza.io"
}
variable "documentation_url" {
  default = "https://akenza.atlassian.net/servicedesk/customer/portals"
}

