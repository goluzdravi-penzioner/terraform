resource "kubernetes_service" "mqtt_gateway_internal" {
  metadata {
    name      = "mqtt-gateway-internal"
    namespace = var.namespace

    labels = {
      app = var.app_name
    }
  }

  spec {
    port {
      protocol    = "TCP"
      port        = 80
      target_port = 8080
    }

    selector = {
      app = var.app_name
    }

    type             = "ClusterIP"
    session_affinity = "None"
  }
}