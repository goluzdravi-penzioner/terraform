resource "kubernetes_service" "core-ui" {
  count = var.enabled ? 1 : 0
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
      port        = 80
      target_port = 8080
      protocol    = "TCP"
    }
    type = "ClusterIP"
  }
}
