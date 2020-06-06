resource "kubernetes_config_map" "user-service-conf" {
  metadata {
    name      = "user-service-conf"
    namespace = var.namespace
  }

  data = {
    SPRING_DATASOURCE_URL                                                 = "jdbc:mysql://${var.db_address}:3306/cera?user=${local.db_user}&serverTimezone=UTC&useLegacyDatetimeCode=false"
    SPRING_DATASOURCE_PASSWORD                                            = var.db_pass
    SPRING_SECURITY_OAUTH2_CLIENT_REGISTRATION_USER-SERVICE_CLIENT-SECRET = var.auth_client_secret
    SPRING_SECURITY_OAUTH2_CLIENT_PROVIDER_USER-SERVICE_TOKEN-URI         = "http://auth-service-internal/oauth/token"
    SECURITY_RESOURCE_JWK_KEY-SET-URI                                     = "http://auth-service-internal/.well-known/jwks.json"
    CORE_URL                                                              = "core.${var.domain}"
    CORE_DOCUMENTATION_URL                                                = "https://akenza.atlassian.net/servicedesk/customer/portals"
    CORE_STATUSPAGE_URL                                                   = "${var.statuspage_url}"
    CORE_SUPPORT_EMAIL                                                    = "${var.support_email_address}"
    CORE_MGMTADDRESS                                                      = "${var.mgmt_email_address}"
    CORE_AUTH_URL                                                         = "https://auth.${var.domain}"
    URL_MELLARIUSV2                                                       = "http://mellarius-v2-internal"
    SERVER_PORT                                                           = "8080"
    MANAGEMENT_SERVER_PORT                                                = "8880"
    OPENTRACING_JAEGER_RATE-LIMITING-SAMPLER_MAX-TRACES-PER-SECOND        = 2
    APIKEY_OUT_MELLARIUSV2                                                = var.apikey_out_mellariusv2
    APIKEY_IN_MELLARIUSV2                                                 = var.apikey_in_mellariusv2
    APIKEY_IN_API-ROUTER                                                  = var.apikey_in_api-router
    RECAPTCHA_SECRET                                                      = var.google_recaptcha_secret_key
  }
}

locals {
  db_user = "${var.cloud_env == "google" ? var.db_user : "${var.db_user}@${var.mysql_name}"}"
}
