resource "kubernetes_stateful_set" "mqtt_broker" {
  metadata {
    name      = var.app_name
    namespace = var.namespace

    labels = {
      app = var.app_name
    }
  }

  spec {
    replicas               = 1
    revision_history_limit = 5

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    service_name = var.app_name

    template {
      metadata {
        labels = {
          app = var.app_name
          env = var.cluster_name
        }

        annotations = {}
      }

      spec {
        container {
          name                     = var.app_name
          image                    = "eclipse-mosquitto:latest"
          termination_message_path = "/dev/termination-log"
          image_pull_policy        = "IfNotPresent"
          volume_mount {
            name       = "mosquitto-conf"
            mount_path = "/mosquitto/config/mosquitto.conf"
            sub_path   = "mosquitto.conf"
          }
          volume_mount {
            name       = "acl-conf"
            mount_path = "/etc/mosquitto/aclfile.conf"
            sub_path   = "aclfile.conf"
          }
          volume_mount {
            name       = "mqtt-broker-db"
            mount_path = "/mosquitto/data/"
          }
        }
        node_selector = { "cloud.google.com/gke-nodepool" = "mqtt" }
        volume {
          name = "mosquitto-conf"

          config_map {
            name = "mqtt-broker-mosquitto-conf"
          }
        }
        volume {
          name = "acl-conf"

          config_map {
            name = "mqtt-broker-acl-conf"
          }
        }
        dns_policy                       = "ClusterFirst"
        restart_policy                   = "Always"
        termination_grace_period_seconds = 30
      }
    }

    update_strategy {
      type = "RollingUpdate"

      rolling_update {
        partition = 1
      }
    }

    # TODO default storage class name is different between cloud providers, make it configurable
    # https://docs.microsoft.com/en-us/azure/aks/azure-disks-dynamic-pv
    volume_claim_template {
      metadata {
        name = "mqtt-broker-db"
      }

      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = local.storage_class_name
        resources {
          requests = {
            storage = "2Gi"
          }
        }
      }
    }
  }
}

locals {
  storage_class_name = "${var.cloud_env == "google" ? "standard" : "default"}"
}
