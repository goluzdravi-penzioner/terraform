resource "kubernetes_config_map" "template-service-conf" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "template-service-conf"
    namespace = var.namespace
  }

  data = {
    SPRING_DATASOURCE_URL                                          = "jdbc:mysql://${var.db_address}:3306/cera?user=${local.db_user}&serverTimezone=UTC&useLegacyDatetimeCode=false"
    SPRING_DATASOURCE_PASSWORD                                     = var.db_pass
    SECURITY_RESOURCE_JWK_KEY-SET-URI                              = "http://auth-service-internal/.well-known/jwks.json"
    OPENTRACING_JAEGER_RATE-LIMITING-SAMPLER_MAX-TRACES-PER-SECOND = 2
    SERVICE_MELLARIUS-V2_HOST                                      = "http://mellarius-v2-internal"
  }
}

locals {
  db_user = "${var.cloud_env == "google" ? var.db_user : "${var.db_user}@${var.mysql_name}"}"
}
