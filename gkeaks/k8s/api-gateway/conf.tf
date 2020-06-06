resource "kubernetes_config_map" "api-gateway-conf" {
  metadata {
    name      = "api-gateway-conf"
    namespace = var.namespace
  }

  data = {
    SPRING_DATASOURCE_URL                                          = "jdbc:mysql://${var.db_address}:3306/cera?user=${local.db_user}&serverTimezone=UTC&useLegacyDatetimeCode=false"
    SPRING_DATASOURCE_PASSWORD                                     = var.db_pass
    OPENTRACING_JAEGER_RATE-LIMITING-SAMPLER_MAX-TRACES-PER-SECOND = 2
    SERVICES_AUTH_URL                                              = "http://auth-service-internal"
    SERVICES_AUTH_CLIENTID                                         = "api-gateway"
    SERVICES_AUTH_CLIENTSECRET                                     = var.auth_client_secret
    SERVICES_MELLARIUS_URL                                         = "http://mellarius-internal"
    SERVICES_DATA-GATEWAY_URL                                      = "http://data-gateway-internal"
    SERVICES_CONNSERVICE_URL                                       = "http://integration-service-internal"
    SERVICES_MELLARIUSV2_URL                                       = "http://mellarius-v2-internal"
    SERVICES_USERSERVICE_URL                                       = "http://user-service-internal"
    SERVICES_INVENTORYSERVICE_URL                                  = "http://inventory-service-internal"
    SERVICES_INTEGRATIONSERVICE_URL                                = "http://integration-service-internal"
    SERVICES_TEMPLATESERVICE_URL                                   = "http://template-service-internal"
    SERVICES_MELLARIUS_KEY                                         = var.mellarius_key
    SERVICES_DATA-GATEWAY_KEY                                      = var.data-gateway_key
    SERVICES_CONNSERVICE_KEY                                       = var.connservice_key
    SERVICES_MELLARIUSV2_KEY                                       = var.mellariusv2_key
    SERVICES_USERSERVICE_KEY                                       = var.userservice_key
    SERVER_PORT                                                    = "8080"
    MANAGEMENT_SERVER_PORT                                         = "8880"
    SPRING_REDIS_HOST                                              = var.redis_host
    SPRING_REDIS_PORT                                              = local.redis_port
    SPRING_REDIS_PASSWORD                                          = var.redis_password
    SPRING_REDIS_SSL                                               = local.redis_ssl_enabled
    SPRING_REDIS_TIMEOUT                                           = "1500"
    RATE-LIMITING_ENABLED                                          = "false"
  }
}

locals {
  db_user           = "${var.cloud_env == "google" ? var.db_user : "${var.db_user}@${var.mysql_name}"}"
  redis_port        = "${var.redis_ssl_port == 0 ? var.redis_port : var.redis_ssl_port}"
  redis_ssl_enabled = "${var.redis_ssl_port == 0 ? "false" : "true"}"
}
