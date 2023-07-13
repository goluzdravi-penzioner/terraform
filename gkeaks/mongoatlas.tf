######## cluster with vpc peering #############
resource "mongodbatlas_network_container" "gcp-test" {
  project_id       = var.mongodbatlas_project_id
  atlas_cidr_block = "10.18.0.0/18"
  provider_name    = "GCP"
}

# Create the peering connection request
resource "mongodbatlas_network_peering" "test" {
  project_id     = var.mongodbatlas_project_id
  container_id   = mongodbatlas_network_container.gcp-test.container_id
  provider_name  = "GCP"
  gcp_project_id = var.project_id
  network_name   = "autopilot-network"
}

# Create the GCP peer
resource "google_compute_network_peering" "peering" {
  name         = "peering-gcp-terraform-test"
  network      = google_compute_network.autopilot.self_link
  peer_network = "https://www.googleapis.com/compute/v1/projects/${mongodbatlas_network_peering.test.atlas_gcp_project_id}/global/networks/${mongodbatlas_network_peering.test.atlas_vpc_name}"
}

# Create the cluster once the peering connection is completed
resource "mongodbatlas_cluster" "test" {
  project_id   = var.mongodbatlas_project_id
  name         = "terraform-manually-test"
  num_shards   = 1

  cluster_type = "REPLICASET"
  replication_specs {
    num_shards = 1
    regions_config {
      region_name     = "EUROPE_WEST_4"
      electable_nodes = 3
      priority        = 7
      read_only_nodes = 0
    }
  }

  auto_scaling_disk_gb_enabled = true
  #mongo_db_major_version       = "4.2"

  # Provider Settings "block"
  provider_name               = "GCP"
  provider_instance_size_name = "M10"

  depends_on = [google_compute_network_peering.peering]
}

##############################################################################
output "mongodbatlas_cluster" {
  value = mongodbatlas_cluster.test
}

output "mongodbatlas_cluster_host" {
  #value = mongodbatlas_cluster.test.connection_strings
  value = flatten(mongodbatlas_cluster.test.connection_strings[*].private_srv) [0]
}

#### create database user and assign privileges to that user
resource "mongodbatlas_database_user" "test" {
  username           = "booq-admin"
  password           = random_password.mongo_password.result
  project_id         = mongodbatlas_cluster.test.project_id
  auth_database_name = "admin"

  roles {
    role_name = "atlasAdmin"
    database_name = "admin"
  }
}

resource "random_password" "mongo_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "google_secret_manager_secret" "mongodbatlas_credentials" {
  secret_id = "mongodb_atlas_password"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "mongodbatlas_user_password" {
  secret = google_secret_manager_secret.mongodbatlas_credentials.id
  secret_data = random_password.mongo_password.result
}

####### allow network access to the cluster ##################
resource "mongodbatlas_project_ip_access_list" "allow_gke" {
  project_id = var.mongodbatlas_project_id
  cidr_block = google_container_cluster.autopilot.cluster_ipv4_cidr
  comment    = "allow access from GKE pods network"
}

resource "mongodbatlas_project_ip_access_list" "allow_gcp_vpc" {
  project_id = var.mongodbatlas_project_id
  cidr_block = google_compute_subnetwork.autopilot.ip_cidr_range
  comment    = "allow access from GKE vpc network"
}