resource "kubernetes_deployment" "mqtt_gateway" {
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
        max_surge       = 1
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
          env {
            name  = "SPRING_PROFILES_ACTIVE"
            value = var.namespace
          }
          env_from {
            config_map_ref {
              name = "${var.app_name}-conf"
            }
          }
          liveness_probe {
            http_get {
              path = "/actuator/info"
              port = 8880
            }

            initial_delay_seconds = 45
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/actuator/health"
              port = 8880
            }

            initial_delay_seconds = 45
            period_seconds        = 10
            success_threshold     = 2
            failure_threshold     = 7
          }
        }

        container {
          image = "jaegertracing/jaeger-agent:1.17"
          name  = "jaeger-agent"
          args  = ["--collector.host-port=jaeger-operator-jaeger-collector.jaeger.svc:14267"]
          port {
            container_port = "5575"
            protocol       = "UDP"
          }
          port {
            container_port = "6831"
            protocol       = "UDP"
          }
          port {
            container_port = "6832"
            protocol       = "UDP"
          }
          port {
            container_port = "5778"
            protocol       = "TCP"
          }

          resources {}
        }
      }
    }
  }
}
