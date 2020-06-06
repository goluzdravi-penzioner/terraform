resource "kubernetes_config_map" "inventory-service-conf" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "inventory-service-conf"
    namespace = var.namespace
  }

  data = {
    SPRING_DATASOURCE_URL                                          = "jdbc:mysql://${var.db_address}:3306/cera?user=${local.db_user}&serverTimezone=UTC&useLegacyDatetimeCode=false"
    SPRING_DATASOURCE_PASSWORD                                     = var.db_pass
    SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_JWK-SET-URI          = "http://auth-service-internal/.well-known/jwks.json"
    URL_MELLARIUS-V2                                               = "http://mellarius-v2-internal"
    URL_INTEGRATION                                                = "http://integration-service-internal"
  }
}

locals {
  db_user = "${var.cloud_env == "google" ? var.db_user : "${var.db_user}@${var.mysql_name}"}"
}
