resource "kubernetes_config_map" "mellarius-v2-conf" {
  metadata {
    name      = "mellarius-v2-conf"
    namespace = var.namespace
  }

  data = {
    SPRING_DATASOURCE_URL                                          = "jdbc:mysql://${var.db_address}:3306/cera?user=${local.db_user}&serverTimezone=UTC&useLegacyDatetimeCode=false"
    SPRING_DATASOURCE_PASSWORD                                     = var.db_pass
    URL_CONNECTIVITYSERVICE                                        = "http://integration-service-internal"
    URL_DATA_GATEWAY                                               = "http://data-gateway-internal"
    URL_USERSERVICE                                                = "http://user-service-internal"
    URL_MELLARIUS-V1                                               = "http://mellarius-internal"
    URL_PLATFORM_HIVEMIND                                          = "https://core.${var.domain}"
    URL_PLATFORM_AUTH                                              = "https://auth.${var.domain}"
    URL_REPOSITORY_MAIL_TEMPLATES                                  = "https://gitlab.hivemind.ch/api/v4/projects/35/repository/files/{path}/raw?ref=master"
    SERVER_PORT                                                    = "8080"
    MANAGEMENT_SERVER_PORT                                         = "8880"
    OPENTRACING_JAEGER_RATE-LIMITING-SAMPLER_MAX-TRACES-PER-SECOND = 2
    SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_JWK-SET-URI          = "http://auth-service-internal/.well-known/jwks.json"
    APIKEY_IN_APIROUTER                                            = var.apikey_in_apirouter
    APIKEY_IN_CONNECTIVITYSERVICE                                  = var.apikey_in_connectivityservice
    APIKEY_IN_DATA_GATEWAY                                         = var.apikey_in_data-gateway
    APIKEY_IN_USERSERVICE                                          = var.apikey_in_userservice
    APIKEY_IN_CRONSERVICE                                          = var.apikey_in_cronservice
    APIKEY_OUT_CONNECTIVITYSERVICE                                 = var.apikey_out_connectivityservice
    APIKEY_OUT_DATA_GATEWAY                                        = var.apikey_out_data-gateway
    APIKEY_OUT_USERSERVICE                                         = var.apikey_out_userservice
    APIKEY_OUT_REPOSITORY_MAIL_TEMPLATES                           = var.apikey_out_repository_mail_templates
    APIKEY_OUT_MAILGUN                                             = var.apikey_out_mailgun
    INTEGRATION_AUTOMATIC-DOMAINS                                  = var.integration_automatic_domains
  }
}

locals {
  db_user = "${var.cloud_env == "google" ? var.db_user : "${var.db_user}@${var.mysql_name}"}"
}

