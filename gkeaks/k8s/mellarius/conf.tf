resource "kubernetes_config_map" "mellarius-conf" {
  metadata {
    name      = "mellarius-conf"
    namespace = var.namespace
  }

  data = {
    SPRING_DATASOURCE_URL                                          = "jdbc:mysql://${var.db_address}:3306/cera?user=${local.db_user}&serverTimezone=UTC&useLegacyDatetimeCode=false"
    SPRING_DATASOURCE_PASSWORD                                     = var.db_pass
    SPRING_DATA_MONGODB_URI                                        = var.mongo_uri
    SPRING_DATA_MONGODB_DATABASE                                   = "mellolam"
    OPENTRACING_JAEGER_RATE-LIMITING-SAMPLER_MAX-TRACES-PER-SECOND = 2
    DATA-GATEWAY_URL                                               = "http://data-gateway-internal"
    CONNECTIVITY-MANAGER_URL                                       = "http://integration-service-internal/v1"
    AUTH_URL                                                       = "https://auth.${var.domain}"
    PLATFORM_URL                                                   = "https://core.${var.domain}"
    PLATFORM_MGMTADDRESS                                           = "ask@akenza.com"
    SERVER_PORT                                                    = "8080"
    MANAGEMENT_SERVER_PORT                                         = "8880"
    OPENTRACING_JAEGER_RATE-LIMITING-SAMPLER_MAX-TRACES-PER-SECOND = 2
    DATA-GATEWAY_KEY                                               = var.data-gateway_key
    CONNECTIVITY-MANAGER_KEY                                       = var.connectivity-manager_key
    RECAPTCHA_SECRET                                               = var.google_recaptcha_secret_key
    MELLARIUSV2_URL                                                = "http://mellarius-v2-internal"
    MELLARIUSV2_KEY                                                = var.mellariusv2_key
  }
}

locals {
  db_user = "${var.cloud_env == "google" ? var.db_user : "${var.db_user}@${var.mysql_name}"}"
}
