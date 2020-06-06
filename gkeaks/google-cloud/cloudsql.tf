resource "random_integer" "random" {
  min = 10
  max = 9999
}

resource "google_sql_database_instance" "ak-core" {
  depends_on       = [google_service_networking_connection.private-service-networking-peering]
  name             = "${var.cluster-name}-${random_integer.random.result}"
  database_version = "MYSQL_5_7"
  settings {
    tier = var.sql_instance_type
    location_preference {
      zone = var.location
    }
    ip_configuration {
      private_network = google_compute_network.ak-core-vpc.self_link
      ipv4_enabled    = true
      dynamic authorized_networks {
        for_each = var.ip_whitelist
        #for_each = local.ip_list

        content {
          name  = authorized_networks.key
          value = authorized_networks.value
        }
      }
    }
    database_flags {
      name  = "log_bin_trust_function_creators"
      value = "on"
    }
    database_flags {
      name  = "event_scheduler"
      value = "on"
    }
  }
  timeouts {
    create = "15m"
  }
}

resource "google_sql_database" "cera_database" {
  name     = "cera"
  instance = google_sql_database_instance.ak-core.name
}

resource "google_sql_database" "cron_database" {
  name     = "cron"
  instance = google_sql_database_instance.ak-core.name
}

resource "google_sql_database" "auth_database" {
  name     = "auth"
  instance = google_sql_database_instance.ak-core.name
}

resource "google_sql_database" "bi-module_database" {
  name     = "bi-module"
  instance = google_sql_database_instance.ak-core.name
}

resource "random_password" "admin_password" {
  length           = 12
  special          = true
  override_special = "_%@"
}

resource "google_sql_user" "admin-user" {
  name     = "akenzaadmin"
  instance = google_sql_database_instance.ak-core.name
  host     = "%"
  password = random_password.admin_password.result
}

data "http" "ip" {
  url = "http://ipinfo.io/"
  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}
locals {
  ip = lookup(tomap(jsondecode(data.http.ip.body)), "ip")
}

locals {
  ip_list = merge(var.ip_whitelist, { "tf-cloud" = local.ip })
}

##############################
### MYSQL users and grants ###
##############################

provider "mysql" {
  endpoint = "${google_sql_database_instance.ak-core.public_ip_address}:3306"
  username = google_sql_user.admin-user.name
  password = google_sql_user.admin-user.password
  #tls      = true
}

resource "random_password" "password" {
  for_each         = toset(var.dbusers)
  length           = 12
  special          = true
  override_special = "_%@"
}

resource "mysql_user" "dbusers" {
  depends_on = [google_sql_database.cera_database, random_password.password]

  for_each = toset(var.dbusers)
  user     = each.value
  host     = "%"
  #tls_option         = "SSL"
  plaintext_password = random_password.password[each.value].result
}

resource "mysql_grant" "dbusers-services" {
  depends_on = [mysql_user.dbusers]

  for_each   = toset(var.dbusers)
  user       = each.value
  host       = "%"
  database   = google_sql_database.cera_database.name
  privileges = ["SELECT", "UPDATE", "DELETE", "EXECUTE", "INSERT"]
}

resource "mysql_grant" "dbusers-auth-service" {
  depends_on = [mysql_user.dbusers]

  user       = "auth-service"
  host       = "%"
  database   = google_sql_database.auth_database.name
  privileges = ["SELECT", "UPDATE", "DELETE", "EXECUTE", "INSERT"]
}


resource "mysql_grant" "dbusers-cron-service" {
  depends_on = [mysql_user.dbusers]

  user       = "cron-service"
  host       = "%"
  database   = google_sql_database.cron_database.name
  privileges = ["SELECT", "UPDATE", "DELETE", "EXECUTE", "INSERT"]
}

resource "mysql_grant" "dbusers-bi-module" {
  depends_on = [mysql_user.dbusers]

  user       = "bi-module"
  host       = "%"
  database   = google_sql_database.bi-module_database.name
  privileges = ["SELECT", "UPDATE", "DELETE", "EXECUTE", "INSERT", "LOCK TABLES"]
}

variable "dbusers" {
  type    = list(string)
  default = ["api-gateway", "auth-service", "bi-module", "connectivity-service", "cron-service", "data-gateway", "inventory-service", "integration-service", "mellarius", "mellarius-v2", "template-service", "user-service"]
}
