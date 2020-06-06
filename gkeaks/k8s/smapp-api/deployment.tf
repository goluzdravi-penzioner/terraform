resource "kubernetes_deployment" "smapp-api" {
  count      = var.enabled ? 1 : 0
  depends_on = [kubernetes_config_map.smapp-api-conf]
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
          env_from {
            config_map_ref {
              name = "${var.app_name}-conf"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "smapp-api-cron" {
  count      = var.enabled ? 1 : 0
  depends_on = [kubernetes_config_map.smapp-api-cron-conf]
  metadata {
    name      = "${var.app_name}-cron"
    namespace = var.namespace
    labels = {
      app = "${var.app_name}-cron"
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
        app = "${var.app_name}-cron"
      }
    }

    template {
      metadata {
        labels = {
          app = "${var.app_name}-cron"
        }
      }

      spec {
        image_pull_secrets {
          name = "docreg"
        }
        container {
          image = "${var.docker_registry}/${var.app_name}:${var.cron_image_tag}"
          name  = "${var.app_name}-cron"
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
              name = "${var.app_name}-cron-conf"
            }
          }
        }
      }
    }
  }
}
