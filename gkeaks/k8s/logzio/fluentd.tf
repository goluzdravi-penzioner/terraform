# also refer to: https://github.com/logzio/logzio-k8s/
# and https://app-nl.logz.io/#/dashboard/data-sources/Kubernetes
resource "kubernetes_secret" "logzio_secret" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "logzio-logs-secret"
    namespace = "kube-system"
  }

  data = {
    logzio-log-shipping-token = var.logzio_token
    logzio-log-listener       = var.logzio_listener
  }
}

resource "kubernetes_service_account" "logzio_fluentd_service_account" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "fluentd"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role" "logzio_fluentd_cluster_role" {
  depends_on = [kubernetes_service_account.logzio_fluentd_service_account]
  count      = var.enabled ? 1 : 0
  metadata {
    name = "fluentd"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "logzio_fluentd_cluster_role_binding" {
  depends_on = [kubernetes_cluster_role.logzio_fluentd_cluster_role]
  count      = var.enabled ? 1 : 0
  metadata {
    name = "fluentd"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "fluentd"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "fluentd"
    namespace = "kube-system"
  }
}

resource "kubernetes_daemonset" "logzio_fluentd_daemonset" {
  depends_on = [kubernetes_cluster_role_binding.logzio_fluentd_cluster_role_binding, kubernetes_secret.logzio_secret]
  count      = var.enabled ? 1 : 0
  metadata {
    name      = "fluentd-logzio"
    namespace = "kube-system"
    labels = {
      k8s-app = "fluentd-logzio"
      version = "v1"
      env     = var.cluster_name
    }
  }

  spec {
    selector {
      match_labels = {
        k8s-app = "fluentd-logzio"
      }
    }

    template {
      metadata {
        labels = {
          k8s-app = "fluentd-logzio"
          version = "v1"
          env     = var.cluster_name
        }
      }

      spec {
        service_account_name            = "fluentd"
        automount_service_account_token = true
        toleration {
          key    = "node-role.kubernetes.io/master"
          effect = "NoSchedule"
        }
        container {
          image = "logzio/logzio-k8s:${var.logzio_fluend_version}"
          name  = "fluentd"

          env {
            name = "LOGZIO_LOG_SHIPPING_TOKEN"
            value_from {
              secret_key_ref {
                name = "logzio-logs-secret"
                key  = "logzio-log-shipping-token"
              }
            }
          }
          env {
            name = "LOGZIO_LOG_LISTENER"
            value_from {
              secret_key_ref {
                name = "logzio-logs-secret"
                key  = "logzio-log-listener"
              }
            }
          }
          env {
            name  = "FLUENTD_SYSTEMD_CONF"
            value = "disable"
          }
          env {
            name  = "FLUENTD_PROMETHEUS_CONF"
            value = "disable"
          }
          resources {
            limits {
              memory = "200Mi"
            }
            requests {
              cpu    = "100m"
              memory = "200Mi"
            }
          }
          volume_mount {
            name       = "varlog"
            mount_path = "/var/log"
          }
          volume_mount {
            name       = "varlibdockercontainers"
            mount_path = "/var/lib/docker/containers"
            read_only  = true
          }
        }
        termination_grace_period_seconds = 30
        volume {
          name = "varlog"
          host_path {
            path = "/var/log"
          }
        }
        volume {
          name = "varlibdockercontainers"
          host_path {
            path = "/var/lib/docker/containers"
          }
        }
      }
    }
  }
}
