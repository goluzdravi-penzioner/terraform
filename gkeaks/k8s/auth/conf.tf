resource "kubernetes_config_map" "auth-service-conf" {
  metadata {
    name      = "auth-service-conf"
    namespace = var.namespace
  }

  data = {
    SPRING_DATASOURCE_URL                                          = "jdbc:mysql://${var.db_address}:3306/auth?user=${local.db_user}&serverTimezone=UTC&useLegacyDatetimeCode=false"
    SPRING_DATASOURCE_PASSWORD                                     = var.db_pass
    SERVER_PORT                                                    = "8080"
    MANAGEMENT_SERVER_PORT                                         = "8880"
    OPENTRACING_JAEGER_RATE-LIMITING-SAMPLER_MAX-TRACES-PER-SECOND = 2

    REDIRECT_URL         = "https://core.${var.domain}"
    REDIRECT_PREVIEW-URL = "https://preview.core.${var.domain}"
    PUBLIC_URL           = "https://auth.${var.domain}"

    JWK_KEY_PATH     = "${var.jwks_keystore_path}"
    JWK_KEY_ALIAS    = "${var.jwks_keystore_alias}"
    JWK_KEY_PASSWORD = "${var.jwks_keystore_pass}"

    SECURITY_CONTENT_POLICY = "default-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; script-src 'self' https://www.google.com/recaptcha/ https://www.gstatic.com/recaptcha/; img-src 'self' data:; object-src 'none'; manifest-src 'self'; font-src 'self' https://fonts.googleapis.com https://fonts.gstatic.com; frame-src 'self' https://www.google.com/recaptcha/; connect-src 'self' https://restcountries.eu/rest/v2/ https://api.core.${var.domain}"
    SECURITY_ALLOWED_ORIGIN = "https://auth.${var.domain}, https://api.core.${var.domain}"

    SECURITY_OAUTH2_PROVIDER_GOOGLE_ENABLED                             = "${var.google_auth}"
    SECURITY_OAUTH2_PROVIDER_GOOGLE_CLIENT_CLIENTID                     = "${var.google_client_id}"
    SECURITY_OAUTH2_PROVIDER_GOOGLE_CLIENT_CLIENTSECRET                 = "${var.google_client_secret}"
    SECURITY_OAUTH2_PROVIDER_GOOGLE_CLIENT_PRE-ESTABLISHED-REDIRECT-URI = "https://auth.${var.domain}/login/google"


    SERVICE_USER-SERVICE_URL                                              = "http://user-service-internal"
    SPRING_SECURITY_OAUTH2_CLIENT_REGISTRATION_AUTH-SERVICE_CLIENT-SECRET = var.auth_client_secret
    SPRING_SECURITY_OAUTH2_CLIENT_PROVIDER_AUTH-SERVICE_TOKEN-URI         = "http://localhost:8080/oauth/token"
  }
}

locals {
  db_user = "${var.cloud_env == "google" ? var.db_user : "${var.db_user}@${var.mysql_name}"}"
}

resource "kubernetes_config_map" "auth-service-frontend-conf" {
  metadata {
    name      = "auth-service-frontend-conf"
    namespace = var.namespace
  }

  data = {
    "app.config.json" = <<JSON
      {
        "APIBaseURL": "https://api.core.${var.domain}",
        "coreBaseURL": "https://core.${var.domain}",
        "siteKey": "${var.google_recaptcha_site_key}",
        "registerAccessible": true,
        "showLoginForm": true,
        "tenant": {
          "name": "${var.product_name}"
        }

      }
      JSON
  }
}
