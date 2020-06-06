resource "google_redis_instance" "redis_cache" {
  depends_on = [google_service_networking_connection.private-service-networking-peering]

  name               = "redis-${var.cluster-name}"
  tier               = "BASIC"
  memory_size_gb     = 1
  location_id        = var.location
  authorized_network = google_compute_network.ak-core-vpc.self_link
  redis_version      = "REDIS_4_0"
  display_name       = "Akenza ${var.cluster-name} Instance"
  reserved_ip_range  = "192.168.0.0/29"
}

resource "google_redis_instance" "redis_cache_smapp" {
  depends_on = [google_service_networking_connection.private-service-networking-peering]

  name               = "redis-${var.cluster-name}-smapp"
  tier               = "BASIC"
  memory_size_gb     = 1
  location_id        = var.location
  authorized_network = google_compute_network.ak-core-vpc.self_link
  redis_version      = "REDIS_4_0"
  display_name       = "Akenza ${var.cluster-name} Instance"
  reserved_ip_range  = "192.168.5.0/29"
}

resource "google_compute_instance" "redis-proxy" {
  depends_on   = [google_redis_instance.redis_cache]

  name         = "redis-proxy"
  machine_type = "f1-micro"
  zone         = var.location

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.node-network.self_link
    access_config {
      // Ephemeral IP
      nat_ip = google_compute_address.redis_proxy.address
    }
  }
 
  metadata_startup_script = data.template_file.haproxy-config.rendered
}

resource "google_compute_address" "redis_proxy" {
  name   = "redis-proxy"
  region = google_compute_subnetwork.node-network.region
}

data "template_file" "haproxy-config" {
  depends_on   = [google_redis_instance.redis_cache, google_redis_instance.redis_cache_smapp]

  template = "${file("${path.module}/haproxy-config.tpl")}"
  vars = {
    redis_host       = google_redis_instance.redis_cache.host
    redis_host_smapp = google_redis_instance.redis_cache_smapp.host 
  }
}

resource "google_compute_firewall" "redis-proxy" {
  name    = "redis-proxy"
  network = google_compute_network.ak-core-vpc.name

  allow {
    protocol = "tcp"
    ports    = ["6379", "6380"]
  }
  source_ranges = ["24.135.13.0/24"]
}

resource "google_compute_firewall" "redis_proxy_ssh" {
  name    = "redis-proxy-ssh"
  network = google_compute_network.ak-core-vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}