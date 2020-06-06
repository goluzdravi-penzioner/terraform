resource "google_container_cluster" "ak-core" {
  name               = var.cluster-name
  min_master_version = data.google_container_engine_versions.latest.latest_master_version
  network            = google_compute_network.ak-core-vpc.name
  subnetwork         = google_compute_subnetwork.node-network.name
  private_cluster_config {
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "172.16.0.32/28"
    enable_private_endpoint = false
  }
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods-${var.cluster-name}"
    services_secondary_range_name = "services-${var.cluster-name}"
  }
  maintenance_policy {
    daily_maintenance_window {
      start_time = "02:00"
    }
  }

  master_authorized_networks_config {
    dynamic cidr_blocks {
      for_each = var.ip_whitelist

      content {
        cidr_block   = cidr_blocks.value
        display_name = cidr_blocks.key
      }
    }
  }
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    username = "akenzaadmin"
    password = random_password.k8s_password.result

    client_certificate_config {
      issue_client_certificate = true
    }
  }
}

## Get latest kubernetes master version ###

data "google_container_engine_versions" "latest" {
  location = var.location
}

resource "google_container_node_pool" "primary_nodes" {
  version    = data.google_container_engine_versions.latest.latest_master_version
  name       = "${var.cluster-name}-node-pool"
  location   = var.location
  cluster    = google_container_cluster.ak-core.name
  node_count = var.gke_node_count
  autoscaling {
    min_node_count = var.gke_min_node_count
    max_node_count = var.gke_max_node_count
  }
  management {
    auto_repair  = true
    auto_upgrade = false
  }
  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }
  node_config {
    preemptible  = true
    machine_type = var.gke_node_type

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform.read-only"
    ]
  }
}

resource "random_password" "k8s_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

## Firewall rule to allow access from gke master to worker nodes for cert-manager webhook

resource "google_compute_firewall" "cert-manager-webhook" {
  depends_on = [google_service_networking_connection.private-service-networking-peering]
  name       = "cert-manager-webhook"
  network    = google_compute_network.ak-core-vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["6433"]
  }
  source_ranges = ["172.16.0.32/28"]
}
