resource "kubernetes_deployment" "timer-service" {
  depends_on = [kubernetes_config_map.timer-service-conf]
  metadata {
    name      = var.app_name
    namespace = var.namespace
    labels = {
      app = var.app_name
    }
  }

  spec {
    replicas = 1
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = 3
        max_unavailable = 0
      }
    }

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
          env = var.cluster_name
        }
      }

      spec {
        image_pull_secrets {
          name = "docreg"
        }
        container {
          image = "${var.docker_registry}/${var.app_name}:${var.image_tag}"
          name  = var.app_name
          resources {
            requests {
              memory = "400Mi"
            }
            limits {
              memory = "600Mi"
            }
          }
          env_from {
            config_map_ref {
              name = "${var.app_name}-conf"
            }
          }
          liveness_probe {
            http_get {
              path = "/live"
              port = 8080
            }

            initial_delay_seconds = 30
            period_seconds        = 5
            success_threshold     = 1
            failure_threshold     = 2
          }

          readiness_probe {
            http_get {
              path = "/ready"
              port = 8080
            }

            initial_delay_seconds = 10
            period_seconds        = 10
            success_threshold     = 2
            failure_threshold     = 7
          }
        }
      }
    }
  }
}
