provider "google" {
  credentials = data.template_file.gcp-credentials.rendered
  project     = var.project
  region      = var.region
  zone        = var.location
}

data "template_file" "gcp-credentials" {
  template = "${file("${path.module}/gcp-auth.tpl")}"

  vars = {
    type                        = var.gcp_auth_type
    project_id                  = var.gcp_auth_project_id
    private_key_id              = var.gcp_auth_private_key_id
    private_key                 = replace(var.gcp_auth_private_key, "\n", "\\n")
    client_email                = var.gcp_auth_client_email
    client_id                   = var.gcp_auth_client_id
    auth_uri                    = var.gcp_auth_auth_uri
    token_uri                   = var.gcp_auth_token_uri
    auth_provider_x509_cert_url = var.gcp_auth_auth_provider_x509_cert_url
    client_x509_cert_url        = var.gcp_auth_client_x509_cert_url
  }
}

terraform {
  backend "remote" {
    organization = "akenza"

    workspaces {
      prefix = "akenza-"
    }
  }
}

provider "kubernetes" {
  version          = "1.10"
  load_config_file = false

  username               = google_container_cluster.ak-core.master_auth.0.username
  password               = google_container_cluster.ak-core.master_auth.0.password
  host                   = google_container_cluster.ak-core.endpoint
  client_certificate     = base64decode(google_container_cluster.ak-core.master_auth.0.client_certificate)
  client_key             = base64decode(google_container_cluster.ak-core.master_auth.0.client_key)
  cluster_ca_certificate = base64decode(google_container_cluster.ak-core.master_auth.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    load_config_file = false

    host                   = google_container_cluster.ak-core.endpoint
    client_certificate     = base64decode(google_container_cluster.ak-core.master_auth.0.client_certificate)
    client_key             = base64decode(google_container_cluster.ak-core.master_auth.0.client_key)
    cluster_ca_certificate = base64decode(google_container_cluster.ak-core.master_auth.0.cluster_ca_certificate)
    username               = google_container_cluster.ak-core.master_auth.0.username
    password               = google_container_cluster.ak-core.master_auth.0.password
  }
}
