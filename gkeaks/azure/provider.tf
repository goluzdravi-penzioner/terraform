#https://github.com/terraform-providers/terraform-provider-azurerm
provider "azurerm" {
  version         = "~>2.9.0"
  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  partner_id      = var.azure_partner_id
  features {}
  #https://www.terraform.io/docs/providers/azurerm/index.html#skip_provider_registration
  skip_provider_registration = true
}

# NOTE this is replaced by Terraform cloud remotely and only used for local testing, also refer to: https://www.terraform.io/docs/cloud/run/run-environment.html
terraform {
  backend "remote" {
    organization = "akenza"

    workspaces {
      prefix = "azure"
    }
  }
}

provider "kubernetes" {
  version          = "1.10"
  load_config_file = false

  host                   = azurerm_kubernetes_cluster.ak-core.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.ak-core.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.ak-core.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.ak-core.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  version        = "0.10.4"
  install_tiller = true
  kubernetes {
    load_config_file = false

    host                   = azurerm_kubernetes_cluster.ak-core.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.ak-core.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.ak-core.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.ak-core.kube_config.0.cluster_ca_certificate)
  }
}
