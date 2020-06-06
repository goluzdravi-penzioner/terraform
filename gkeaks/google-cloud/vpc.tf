resource "google_compute_network" "ak-core-vpc" {
  name                    = var.cluster-name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "node-network" {
  name                     = "node-subnetwork-${var.cluster-name}"
  private_ip_google_access = true
  ip_cidr_range            = "10.4.0.0/16"
  network                  = google_compute_network.ak-core-vpc.self_link
  secondary_ip_range = [{
    range_name    = "pods-${var.cluster-name}"
    ip_cidr_range = "10.5.0.0/16"
    },
    {
      range_name    = "services-${var.cluster-name}"
      ip_cidr_range = "10.6.0.0/16"
    }
  ]
}

#############################################################################

resource "google_compute_global_address" "private_ip_range" {
  name          = "private-ip-range-${var.cluster-name}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = google_compute_network.ak-core-vpc.self_link
}

resource "google_service_networking_connection" "private-service-networking-peering" {
  depends_on              = [google_compute_global_address.private_ip_range]
  network                 = google_compute_network.ak-core-vpc.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = ["${google_compute_global_address.private_ip_range.name}"]
}

############################### Setup CloudNAT ###########################################

resource "google_compute_router" "nat-router" {
  name    = "nat-router"
  region  = google_compute_subnetwork.node-network.region
  network = google_compute_network.ak-core-vpc.self_link
}

resource "google_compute_address" "nat-address" {
  name   = "nat-gw-ip"
  region = google_compute_subnetwork.node-network.region
}

resource "google_compute_router_nat" "nat_router" {
  name   = "router-nat"
  router = google_compute_router.nat-router.name
  region = google_compute_router.nat-router.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.nat-address.*.self_link

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.node-network.self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
