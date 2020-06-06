resource "kubernetes_config_map" "integration-service-conf" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "integration-service-conf"
    namespace = var.namespace
  }

  data = {
    SPRING_DATASOURCE_URL                                          = "jdbc:mysql://${var.db_address}:3306/cera?user=${local.db_user}&serverTimezone=UTC&useLegacyDatetimeCode=false"
    SPRING_DATASOURCE_PASSWORD                                     = var.db_pass
    SERVICE_MELLARIUS_HOST                                         = "http://mellarius-internal"
    SERVICE_INVENTORY_HOST                                         = "http://inventory-service-internal"
    SERVICE_MELLARIUS-V2_HOST                                      = "http://mellarius-v2-internal"
    SERVICE_CRON_HOST                                              = "http://cron-service-internal"
    SERVICE_DATA-GATEWAY_PUBLIC-URL                                = "https://data-gateway.core.${var.domain}"
    SECURITY_RESOURCE_JWK_KEY-SET-URI                              = "http://auth-service-internal/.well-known/jwks.json"
    SERVER_PORT                                                    = "8080"
    MANAGEMENT_SERVER_PORT                                         = "8880"
    OPENTRACING_JAEGER_RATE-LIMITING-SAMPLER_MAX-TRACES-PER-SECOND = 2
    ENCRYPTION_NAME_CURRENT                                        = "${var.encryption_name_current}"
    ENCRYPTION_KEY_CURRENT                                         = "${var.encryption_key_current}"
    ENCRYPTION_NAME_OLD                                            = "${var.encryption_name_old}"
    ENCRYPTION_KEY_OLD                                             = "${var.encryption_key_old}"
    SPRING_REDIS_HOST                                              = var.redis_host
    SPRING_REDIS_PORT                                              = local.redis_port
    SPRING_REDIS_PASSWORD                                          = var.redis_password
    SPRING_REDIS_SSL                                               = local.redis_ssl_enabled
    SPRING_REDIS_TIMEOUT                                           = "1500"
    LEGACY_INTEGRATION_LORIOT_ID                                   = "${var.legacy_integration_loriot_id}"
    LEGACY_INTEGRATION_SWISSCOM_ID                                 = "${var.legacy_integration_swisscom_id}"
    LEGACY_INTEGRATION_TTN_ID                                      = "${var.legacy_integration_ttn_id}"
    INTEGRATION_TYPES                                              = "${var.integration_types}"
    INTEGRATION_LORIOT_KEY                                         = "${var.integration_loriot_key}"
    INTEGRATION_SWISSCOM_KEY                                       = "${var.integration_swisscom_key}"
    INTEGRATION_TTN_KEY                                            = "${var.integration_ttn_key}"
    INTEGRATION_LORIOT_ENABLED                                     = var.integration_loriot_enabled
    INTEGRATION_SWISSCOM_ENABLED                                   = var.integration_swisscom_enabled
    INTEGRATION_TTN_ENABLED                                        = var.integration_ttn_enabled
    AKENZA_CAPTURE_ADDRESS                                         = "http://data-gateway.core.${var.domain}/v2/up"
    MELLARIUSV2URL                                                 = "http://mellarius-v2-internal"
    URL_CRONSERVICE                                                = "http://cron-service-internal"
    NETEMERA_LORA_AUTHORIZATION_CLIENT_ID                          = "akenza-core"
    NETEMERA_LORA_AUTHORIZATION_CLIENT_SECRET                      = "OVoCr8wj3cggKX0im6XL99B24j7ltInoHEKvzZQYjBYeyd-xnumfrcnA_zQuCCEg"
    APIKEY_IN_DATA-GATEWAY                                         = var.apikey_in_data-gateway
    APIKEY_IN_APISFUCUS                                            = var.apikey_in_data-gateway
    APIKEY_IN_APIROUTER                                            = var.apikey_in_apirouter
    APIKEY_IN_MELLARIUSV1                                          = var.apikey_in_mellariusv1
    APIKEY_IN_MELLARIUSV2                                          = var.apikey_in_mellariusv2
    APIKEY_IN_CRONSERVICE                                          = var.apikey_in_cronservice
    APIKEY_OUT_MELLARIUSV2                                         = var.apikey_out_mellariusv2
    APIKEY_OUT_CRONSERVICE                                         = var.apikey_out_cronservice
  }
}

locals {
  db_user           = "${var.cloud_env == "google" ? var.db_user : "${var.db_user}@${var.mysql_name}"}"
  redis_port        = "${var.redis_ssl_port == 0 ? var.redis_port : var.redis_ssl_port}"
  redis_ssl_enabled = "${var.redis_ssl_port == 0 ? "false" : "true"}"
}
