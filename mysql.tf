### Creates a list of users,passwords from the list and grant priviledges to those users ###
resource "random_password" "password" {
  for_each         = toset(var.dbusers)
  length           = 12
  special          = true
  override_special = "_%@"
}

resource "mysql_user" "dbusers" {
  depends_on = [google_sql_database.cera_database, random_password.password]

  for_each   = toset(var.dbusers)
  user               = each.value
  host               = "%"
  #tls_option         = "SSL"
  plaintext_password = random_password.password[each.value].result
}

resource "mysql_grant" "dbusers-services" {
  depends_on = [mysql_user.dbusers]

  for_each = toset(var.dbusers)
  user       = each.value
  host       = "%"
  database   = "cera"
  privileges = ["SELECT", "UPDATE", "DELETE", "EXECUTE", "INSERT"]
}

resource "mysql_grant" "dbusers-cron-service" {
  depends_on = [mysql_user.dbusers]

  user       = "cron-service"
  host       = "%"
  database   = "cron"
  privileges = ["SELECT", "UPDATE", "DELETE", "EXECUTE", "INSERT"]
}

variable "dbusers" {
  type    = list(string)
  default = ["api-gateway", "auth-service", "connectivity-service", "cron-service", "data-gateway", "data-service", "inventory-service", "integration-service", "mellarius", "mellarius-v2", "template-service", "user-service"]
}

### Example of dynamic block in resource
        ip_configuration {
            private_network = google_compute_network.ak-core-vpc.self_link
            ipv4_enabled = true
            dynamic authorized_networks {
              for_each = var.ip_whitelist

              content {
                name  = authorized_networks.key
                value = authorized_networks.value
              }
            }           
        }

variable "ip_whitelist" {
  type = map(string)
  default = {
      Belgrade-office = "82.214.86.83/32"
  }
}
