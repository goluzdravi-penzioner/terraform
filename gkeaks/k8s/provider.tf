# NOTE this is replaced by Terraform cloud remotely and only used for local testing, also refer to: https://www.terraform.io/docs/cloud/run/run-environment.html
terraform {
  backend "remote" {
    organization = "akenza"

    workspaces {
      prefix = "akenza-"
    }
  }
}

provider "kubernetes" {
  load_config_file       = false
  host                   = data.terraform_remote_state.infrastructure_state.outputs.kube_host
  username               = data.terraform_remote_state.infrastructure_state.outputs.k8s_username
  password               = data.terraform_remote_state.infrastructure_state.outputs.k8s_password
  client_certificate     = base64decode(data.terraform_remote_state.infrastructure_state.outputs.client_certificate)
  client_key             = base64decode(data.terraform_remote_state.infrastructure_state.outputs.client_key)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.infrastructure_state.outputs.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    load_config_file       = false
    host                   = data.terraform_remote_state.infrastructure_state.outputs.kube_host
    username               = data.terraform_remote_state.infrastructure_state.outputs.k8s_username
    password               = data.terraform_remote_state.infrastructure_state.outputs.k8s_password
    client_certificate     = base64decode(data.terraform_remote_state.infrastructure_state.outputs.client_certificate)
    client_key             = base64decode(data.terraform_remote_state.infrastructure_state.outputs.client_key)
    cluster_ca_certificate = base64decode(data.terraform_remote_state.infrastructure_state.outputs.cluster_ca_certificate)
  }
}

data "terraform_remote_state" "infrastructure_state" {
  backend = "remote"
  config = {
    organization = "akenza"
    workspaces = {
      name = var.infrastructure_workspace_name
    }
  }
}
