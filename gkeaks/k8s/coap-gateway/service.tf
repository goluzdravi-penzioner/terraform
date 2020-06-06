resource "kubernetes_service" "coap-gateway" {
  metadata {
    name      = "${var.app_name}-internal"
    namespace = var.namespace
    labels = {
      app = var.app_name
    }
  }
  spec {
    selector = {
      app = var.app_name
    }
    port {
      port        = 5683
      target_port = 5683
      protocol    = "UDP"
    }
    type = "ClusterIP"
  }
}
