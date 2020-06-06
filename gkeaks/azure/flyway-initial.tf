resource "kubernetes_job" "flyway-auth-initial" {
  depends_on = [azurerm_mysql_database.auth]
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
            value = "${azurerm_mysql_server.ak-core.administrator_login}@${azurerm_mysql_server.ak-core.name}"
          }
          env {
            name  = "DB_PASSWORD"
            value = azurerm_mysql_server.ak-core.administrator_login_password
          }
          env {
            name  = "DB_URL"
            value = "jdbc:mysql://${azurerm_mysql_server.ak-core.fqdn}:3306/auth?useSSL=true&requireSSL=false&serverTimezone=UTC&useLegacyDatetimeCode=false"
          }
        }
        restart_policy = "Never"
      }
    }
  }
}

resource "kubernetes_job" "flyway-initial" {
  depends_on = [azurerm_mysql_database.cera]
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
            value = "${azurerm_mysql_server.ak-core.administrator_login}@${azurerm_mysql_server.ak-core.name}"
          }
          env {
            name  = "DB_PASSWORD"
            value = azurerm_mysql_server.ak-core.administrator_login_password
          }
          env {
            name  = "DB_URL"
            value = "jdbc:mysql://${azurerm_mysql_server.ak-core.fqdn}:3306/cera?useSSL=true&requireSSL=false&serverTimezone=UTC&useLegacyDatetimeCode=false"
          }
        }
        restart_policy = "Never"
      }
    }
  }
}

resource "kubernetes_job" "flyway-cron-initial" {
  depends_on = [azurerm_mysql_database.cron]
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
            value = "${azurerm_mysql_server.ak-core.administrator_login}@${azurerm_mysql_server.ak-core.name}"
          }
          env {
            name  = "DB_PASSWORD"
            value = azurerm_mysql_server.ak-core.administrator_login_password
          }
          env {
            name  = "DB_URL"
            value = "jdbc:mysql://${azurerm_mysql_server.ak-core.fqdn}:3306/cron?useSSL=true&requireSSL=false&serverTimezone=UTC&useLegacyDatetimeCode=false"
          }
        }
        restart_policy = "Never"
      }
    }
  }
}
