resource "kubernetes_job" "flyway-auth-initial" {
  depends_on = [google_sql_database.auth_database]
  metadata {
    name      = "auth-service-migrator-initial"
    namespace = kubernetes_namespace.ak-core.metadata[0].name
  }
  spec {
    template {
      metadata {}
      spec {
        image_pull_secrets {
          name = "docreg"
        }
        container {
          name              = "auth-service-db-migrator"
          image             = "${var.registry}/auth-service-db-migrator:${var.auth-service-db-migrator_image}"
          image_pull_policy = "Always"
          env {
            name  = "DB_USER"
            value = google_sql_user.admin-user.name
          }
          env {
            name  = "DB_PASSWORD"
            value = google_sql_user.admin-user.password
          }
          env {
            name  = "DB_URL"
            value = "jdbc:mysql://${google_sql_database_instance.ak-core.private_ip_address}:3306/auth?useSSL=true&requireSSL=false&serverTimezone=UTC&useLegacyDatetimeCode=false"
          }
        }
        restart_policy = "Never"
      }
    }
  }
}

resource "kubernetes_job" "flyway-cera-initial" {
  #NOTE needs to depend on auth as the schema needs to be created for migration of existing db, which is done as a migration
  depends_on = [google_sql_database.cera_database, kubernetes_job.flyway-auth-initial]
  metadata {
    name      = "mellarius-db-migrator-initial"
    namespace = kubernetes_namespace.ak-core.metadata[0].name
  }
  spec {
    template {
      metadata {}
      spec {
        image_pull_secrets {
          name = "docreg"
        }
        container {
          name              = "mellarius-db-migrator-initial"
          image             = "${var.registry}/mellarius-v2-db-migrator:${var.mellarius-db-migrator_image}"
          image_pull_policy = "Always"
          env {
            name  = "DB_USER"
            value = google_sql_user.admin-user.name
          }
          env {
            name  = "DB_PASSWORD"
            value = google_sql_user.admin-user.password
          }
          env {
            name  = "DB_URL"
            value = "jdbc:mysql://${google_sql_database_instance.ak-core.private_ip_address}:3306/cera?useSSL=true&requireSSL=false&serverTimezone=UTC&useLegacyDatetimeCode=false"
          }
        }
        restart_policy = "Never"
      }
    }
  }
}

resource "kubernetes_job" "flyway-cron-initial" {
  depends_on = [google_sql_database.cron_database]
  metadata {
    name      = "cron-db-migrator-initial"
    namespace = kubernetes_namespace.ak-core.metadata[0].name
  }
  spec {
    template {
      metadata {}
      spec {
        image_pull_secrets {
          name = "docreg"
        }
        container {
          name              = "cron-db-migrator"
          image             = "${var.registry}/cron-service-db-migrator:${var.cron-service-db-migrator_image}"
          image_pull_policy = "Always"
          env {
            name  = "DB_USER"
            value = google_sql_user.admin-user.name
          }
          env {
            name  = "DB_PASSWORD"
            value = google_sql_user.admin-user.password
          }
          env {
            name  = "DB_URL"
            value = "jdbc:mysql://${google_sql_database_instance.ak-core.private_ip_address}:3306/cron?useSSL=true&requireSSL=false&serverTimezone=UTC&useLegacyDatetimeCode=false"
          }
        }
        restart_policy = "Never"
      }
    }
  }
}
