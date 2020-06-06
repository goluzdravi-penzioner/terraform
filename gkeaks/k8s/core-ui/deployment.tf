resource "kubernetes_deployment" "core-ui" {
  count      = var.enabled ? 1 : 0
  depends_on = [kubernetes_config_map.core-ui-nginx-conf]
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
              memory = "100Mi"
            }
            limits {
              memory = "200Mi"
            }
          }
          volume_mount {
            name       = "nginx-config"
            mount_path = "/etc/nginx/nginx.conf"
            sub_path   = "nginx.conf"
          }
          volume_mount {
            name       = "app-config"
            mount_path = "/usr/share/nginx/html/config"
          }
        }
        volume {
          name = "nginx-config"
          config_map {
            name = "core-ui-nginx-conf"
          }
        }
        volume {
          name = "app-config"
          config_map {
            name = "core-ui-app-conf"
          }
        }
      }
    }
  }
}
