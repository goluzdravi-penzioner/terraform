resource "kubernetes_config_map" "cron-service-conf" {
  metadata {
    name      = "cron-service-conf"
    namespace = var.namespace
  }

  data = {
    SPRING_DATASOURCE_URL      = "jdbc:mysql://${var.db_address}:3306/cron?user=${local.db_user}&serverTimezone=UTC&useLegacyDatetimeCode=false"
    SPRING_DATASOURCE_PASSWORD = var.db_pass

    URL_CONNECTIVITYSERVICE                                               = "http://integration-service-internal"
    URL_INTEGRATION_SERVICE                                               = "http://integration-service-internal"
    SECURITY_RESOURCE_JWK_KEY-SET-URI                                     = "http://auth-service-internal/.well-known/jwks.json"
    SPRING_SECURITY_OAUTH2_CLIENT_REGISTRATION_CRON-SERVICE_CLIENT-ID     = "cron-service"
    SPRING_SECURITY_OAUTH2_CLIENT_REGISTRATION_CRON-SERVICE_CLIENT-SECRET = var.auth_client_secret
    SPRING_SECURITY_OAUTH2_CLIENT_PROVIDER_CRON-SERVICE_TOKEN-URI         = "http://auth-service-internal/oauth/token"
    KEY_OUT_CONNECTIVITYSERVICE                                           = var.key_out_connectivityservice
    KEY_IN_CONNECTIVITYSERVICE                                            = var.key_in_connectivityservice
    SERVER_PORT                                                           = "8080"
    MANAGEMENT_SERVER_PORT                                                = "8880"
    OPENTRACING_JAEGER_RATE-LIMITING-SAMPLER_MAX-TRACES-PER-SECOND        = 2
  }
}

locals {
  db_user = "${var.cloud_env == "google" ? var.db_user : "${var.db_user}@${var.mysql_name}"}"
}
