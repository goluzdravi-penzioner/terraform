resource "kubernetes_service" "mqtt_broker_internal" {
  metadata {
    name      = "mqtt-broker-internal"
    namespace = var.namespace

    labels = {
      app = var.app_name
    }
  }

  spec {
    port {
      protocol    = "TCP"
      port        = 1883
      target_port = "1883"
    }

    selector = {
      app = var.app_name
    }

    type             = "ClusterIP"
    session_affinity = "None"
  }
}
