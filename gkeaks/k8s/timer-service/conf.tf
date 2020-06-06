resource "kubernetes_config_map" "timer-service-conf" {
  metadata {
    name      = "timer-service-conf"
    namespace = var.namespace
  }

  data = {
    GW_BASE = "http://data-gateway-internal"
    PORT    = "8080"
  }
}
