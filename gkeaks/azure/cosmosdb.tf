resource "azurerm_cosmosdb_account" "mongodb" {
  capabilities {
    name = "EnableMongo"
  }
  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 10
    max_staleness_prefix    = 200
  }
  geo_location {
    location          = var.location
    failover_priority = 0
  }
  ip_range_filter                   = "104.42.195.92,40.76.54.131,52.176.6.30,52.169.50.45,52.187.184.26,82.214.86.83,81.62.179.58,51.154.201.138"
  is_virtual_network_filter_enabled = true
  kind                              = "MongoDB"
  location                          = var.location
  name                              = "mongodbuser-${var.cus_name}"
  offer_type                        = "Standard"
  resource_group_name               = var.resource_group

  virtual_network_rule {
    id = azurerm_subnet.nodes.id
  }
}

resource "azurerm_cosmosdb_mongo_database" "device_data_database" {
  name                = "mellolam"
  resource_group_name = var.resource_group
  account_name        = azurerm_cosmosdb_account.mongodb.name
}

#https://docs.microsoft.com/en-us/azure/cosmos-db/mongodb-indexing
#TODO use Mongo Atlas provider on Azure: https://www.terraform.io/docs/providers/mongodbatlas/index.html
resource "azurerm_cosmosdb_mongo_collection" "data" {
  name                = "data"
  resource_group_name = var.resource_group
  account_name        = azurerm_cosmosdb_account.mongodb.name
  database_name       = azurerm_cosmosdb_mongo_database.device_data_database.name
  shard_key           = "deviceId"
  throughput          = var.data_rus

  index {
    keys   = ["deviceId"]
    unique = false
  }
}

resource "azurerm_cosmosdb_mongo_collection" "kpi" {
  name                = "kpi"
  resource_group_name = var.resource_group
  account_name        = azurerm_cosmosdb_account.mongodb.name
  database_name       = azurerm_cosmosdb_mongo_database.device_data_database.name
  shard_key           = "type"

  throughput = 400
}

#https://docs.mongodb.com/manual/core/index-creation/
resource "kubernetes_job" "mongo-index-creator-initial" {
  depends_on = [azurerm_cosmosdb_mongo_collection.data, azurerm_cosmosdb_mongo_collection.kpi]
  metadata {
    name      = "mongo-index-creator-initial"
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
          name              = "mongo-index-creator"
          image             = "${var.registry}/mongo-db-index-creator:${var.mongo-db-index-creator_image}"
          image_pull_policy = "Always"
          env {
            name  = "DB_URI"
            value = azurerm_cosmosdb_account.mongodb.connection_strings.0
          }
          env {
            name  = "DB_NAME"
            value = azurerm_cosmosdb_mongo_database.device_data_database.name
          }
        }
        restart_policy = "Never"
      }
    }
  }
}
