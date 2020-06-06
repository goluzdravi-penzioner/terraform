resource "random_string" "auth_clients_secret" {
  length = 16
  override_special = "!@#$%&*-_=+?"
}

resource "kubernetes_config_map" "flyway-auth-clients-conf" {
  metadata {
    name      = "flyway-auth-clients-conf"
    namespace = var.namespace
  }
  #TODO refer to: https://flywaydb.org/getstarted/repeatable
  data = {
    "R__add_automated_auth_clients.sql" = <<SQL
     REPLACE INTO `auth`.`oauth_client_details`
     (`client_id`,
     `client_secret`,
     `scope`,
     `authorized_grant_types`,
     `web_server_redirect_uri`,
     `access_token_validity`,
     `refresh_token_validity`,
     `autoapprove`,
     `logout_return_to_uri`)
     VALUES
     ('akenza-core',
     '${bcrypt(random_string.auth_clients_secret.result)}',
     'core.ui,core.api',
     'password,refresh_token,implicit,authorization_code,client_credentials',
     'https://core.${var.domain},https://core.${var.domain}/,https://core.${var.domain}/assets/silent-refresh.html',
     '7200',
     '18000',
     'core.ui,core.api',
     'https://core.${var.domain}/profile/logout,https://preview.core.${var.domain}');

     REPLACE INTO `auth`.`oauth_client_details`
     (`client_id`,
     `client_secret`,
     `scope`,
     `authorized_grant_types`,
     `web_server_redirect_uri`,
     `access_token_validity`,
     `refresh_token_validity`,
     `autoapprove`)
     VALUES
     ('api-gateway',
     '${bcrypt(random_string.auth_clients_secret.result)}',
     'core.ui,core.api',
     'password,refresh_token,implicit,authorization_code,client_credentials',
     'https://core.${var.domain},https://core.${var.domain}/',
     '7200',
     '18000',
     'core.ui,core.api');

     REPLACE INTO `auth`.`oauth_client_details`
     (`client_id`,
     `client_secret`,
     `scope`,
     `authorized_grant_types`,
     `web_server_redirect_uri`,
     `access_token_validity`,
     `refresh_token_validity`)
     VALUES
     ('cron-service',
     '${bcrypt(random_string.auth_clients_secret.result)}',
     'core.system,core.api',
     'client_credentials',
     'https://core.${var.domain},https://core.${var.domain}/,https://core.${var.domain}/assets/silent-refresh.html${local.additional_login_redirect_urls}',
     '36000',
     '18000');

     REPLACE INTO `auth`.`oauth_client_details`
     (`client_id`,
     `client_secret`,
     `scope`,
     `authorized_grant_types`,
     `web_server_redirect_uri`,
     `access_token_validity`,
     `refresh_token_validity`,
     `autoapprove`,
     `logout_return_to_uri`)
     VALUES
     ('new-core',
     '${bcrypt(random_string.auth_clients_secret.result)}',
     'core.ui,core.api',
     'password,refresh_token,implicit,authorization_code,client_credentials',
     'https://preview.core.${var.domain},https://preview.core.${var.domain}/,https://preview.core.${var.domain}/assets/silent-refresh.html${local.additional_login_redirect_urls}',
     '3600',
     '18000',
     'core.ui,core.api',
     'https://preview.core.${var.domain}');

     REPLACE INTO `auth`.`oauth_client_details`
     (`client_id`,
     `client_secret`,
     `scope`,
     `authorized_grant_types`,
     `web_server_redirect_uri`,
     `access_token_validity`,
     `refresh_token_validity`)
     VALUES
     ('user-service',
     '${bcrypt(random_string.auth_clients_secret.result)}',
     'core.system,core.api',
     'client_credentials',
     '',
     '36000',
     '18000');

     REPLACE INTO `auth`.`oauth_client_details`
     (`client_id`,
     `client_secret`,
     `scope`,
     `authorized_grant_types`,
     `web_server_redirect_uri`,
     `access_token_validity`,
     `refresh_token_validity`)
     VALUES
     ('auth-service',
     '${bcrypt(random_string.auth_clients_secret.result)}',
     'core.system,core.api,core.auth',
     'client_credentials',
     '',
     '36000',
     '18000');

      REPLACE INTO `auth`.`oauth_client_details`
     (`client_id`,
     `client_secret`,
     `scope`,
     `authorized_grant_types`,
     `web_server_redirect_uri`,
     `access_token_validity`,
     `refresh_token_validity`,
     `autoapprove`,
     `logout_return_to_uri`)
     VALUES
     ('smapp-web',
     '${bcrypt(random_string.auth_clients_secret.result)}',
     'core.api,core.smapp',
     'password,refresh_token,implicit,authorization_code',
     'https://app.${var.domain},https://app.${var.domain}/assets/silent-refresh.html',
     '7200',
     '18000',
     'core.api,core.smapp',
     'https://app.core.${var.domain}');
      SQL
  }
}

resource "kubernetes_job" "flyway-auth" {
  depends_on = [kubernetes_config_map.flyway-auth-clients-conf]
  metadata {
    name      = "auth-service-db-migrator"
    namespace = var.namespace
  }
  spec {
    template {
      metadata {
        labels = {
          env = var.cluster_name
        }
      }
      spec {
        image_pull_secrets {
          name = "docreg"
        }
        volume {
          name = "auth-clients"
          config_map {
            name = kubernetes_config_map.flyway-auth-clients-conf.metadata[0].name
          }
        }
        container {
          name              = "auth-service-db-migrator"
          image             = "${var.docker_registry}/auth-service-db-migrator:${var.auth-service-db-migrator_image}"
          image_pull_policy = "Always"
          volume_mount {
            name       = "auth-clients"
            mount_path = "/flyway/sql/auth-clients"
          }
          env {
            name  = "DB_USER"
            value = local.db_user
          }
          env {
            name  = "DB_PASSWORD"
            value = data.terraform_remote_state.infrastructure_state.outputs.mysql_flyway_pass
          }
          env {
            name  = "DB_URL"
            value = "jdbc:mysql://${data.terraform_remote_state.infrastructure_state.outputs.mysql}:3306/auth?useSSL=true&requireSSL=false&serverTimezone=UTC&useLegacyDatetimeCode=false"
          }
        }
        restart_policy = "Never"
      }
    }
  }
}

resource "kubernetes_job" "flyway-cera" {
  metadata {
    name      = "mellarius-db-migrator"
    namespace = var.namespace
  }
  spec {
    template {
      metadata {
        labels = {
          env = var.cluster_name
        }
      }
      spec {
        image_pull_secrets {
          name = "docreg"
        }
        container {
          name              = "mellarius-db-migrator"
          image             = "${var.docker_registry}/mellarius-v2-db-migrator:${var.mellarius-db-migrator_image}"
          image_pull_policy = "Always"
          env {
            name  = "DB_USER"
            value = local.db_user
          }
          env {
            name  = "DB_PASSWORD"
            value = data.terraform_remote_state.infrastructure_state.outputs.mysql_flyway_pass
          }
          env {
            name  = "DB_URL"
            value = "jdbc:mysql://${data.terraform_remote_state.infrastructure_state.outputs.mysql}:3306/cera?useSSL=true&requireSSL=false&serverTimezone=UTC&useLegacyDatetimeCode=false"
          }
        }
        restart_policy = "Never"
      }
    }
  }
}

resource "kubernetes_job" "flyway-cron" {
  metadata {
    name      = "cron-db-migrator"
    namespace = var.namespace
  }
  spec {
    template {
      metadata {
        labels = {
          env = var.cluster_name
        }
      }
      spec {
        image_pull_secrets {
          name = "docreg"
        }
        container {
          name              = "cron-db-migrator"
          image             = "${var.docker_registry}/cron-service-db-migrator:${var.cron-service-db-migrator_image}"
          image_pull_policy = "Always"
          env {
            name  = "DB_USER"
            value = local.db_user
          }
          env {
            name  = "DB_PASSWORD"
            value = data.terraform_remote_state.infrastructure_state.outputs.mysql_flyway_pass
          }
          env {
            name  = "DB_URL"
            value = "jdbc:mysql://${data.terraform_remote_state.infrastructure_state.outputs.mysql}:3306/cron?useSSL=true&requireSSL=false&serverTimezone=UTC&useLegacyDatetimeCode=false"
          }
        }
        restart_policy = "Never"
      }
    }
  }
}

resource "kubernetes_job" "flyway-smapp-api" {
  metadata {
    name      = "smapp-api-db-migrator"
    namespace = var.namespace
  }
  spec {
    template {
      metadata {
        labels = {
          env = var.cluster_name
        }
      }
      spec {
        image_pull_secrets {
          name = "docreg"
        }
        container {
          name              = "smapp-api-db-migrator"
          image             = "${var.docker_registry}/smapp-api-db-migrator:${var.smapp-api-db-migrator_image}"
          image_pull_policy = "Always"
          env {
            name  = "DB_USER"
            value = local.db_user
          }
          env {
            name  = "DB_PASSWORD"
            value = data.terraform_remote_state.infrastructure_state.outputs.mysql_flyway_pass
          }
          env {
            name  = "DB_URL"
            value = "jdbc:mysql://${data.terraform_remote_state.infrastructure_state.outputs.mysql}:3306/bi-module?useSSL=true&requireSSL=false&serverTimezone=UTC&useLegacyDatetimeCode=false"
          }
        }
        restart_policy = "Never"
      }
    }
  }
}


locals {
  db_user                        = "${var.cloud_env == "google" ? data.terraform_remote_state.infrastructure_state.outputs.mysql_flyway_user : "${data.terraform_remote_state.infrastructure_state.outputs.mysql_flyway_user}@${data.terraform_remote_state.infrastructure_state.outputs.mysql_name}"}"
  additional_login_redirect_urls = "${var.additional_login_redirect_urls != "" ? ",${var.additional_login_redirect_urls}" : ""}"
}
