resource "random_id" "log_analytics_workspace_name_suffix" {
  count               = var.log_analytics ? 1 : 0
  byte_length = 8
}

resource "azurerm_log_analytics_workspace" "ak-core" {
  count               = var.log_analytics ? 1 : 0
  # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
  name                = "${var.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix[count.index].dec}"
  location            = var.log_analytics_workspace_location
  resource_group_name = var.resource_group
  sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "ak-core" {
  count               = var.log_analytics ? 1 : 0
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.ak-core[count.index].location
  resource_group_name   = var.resource_group
  workspace_resource_id = azurerm_log_analytics_workspace.ak-core[count.index].id
  workspace_name        = azurerm_log_analytics_workspace.ak-core[count.index].name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "azurerm_kubernetes_cluster" "ak-core" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group
  dns_prefix          = var.dns_prefix

  lifecycle {
    ignore_changes = [
      default_node_pool,
      addon_profile,
    ]
  }

  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = var.ssh_public_key
    }
  }

  default_node_pool {
    name                = "default"
    node_count          = var.default_nodepool_node_count
    max_count           = var.default_nodepool_max_count
    min_count           = var.default_nodepool_min_count
    enable_auto_scaling = true
    vm_size             = var.default_nodepool_vm_size
    vnet_subnet_id      = azurerm_subnet.nodes.id
  }

  service_principal {
    client_id     = var.azure_client_id
    client_secret = var.azure_client_secret
  }

  # Uncomment this block when enabling log_analitics
  # addon_profile {
  #   oms_agent {
  #     enabled                    = true
  #     log_analytics_workspace_id = azurerm_log_analytics_workspace.ak-core[0].id
  #   }
  # }

  tags = {
    Environment = var.cus_name
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "efk" {
  count                 = var.elk_monitoring ? 1 : 0
  name                  = "${var.cus_name}-efk"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.ak-core.id
  vm_size               = var.efk_nodepool_vm_size
  node_count            = var.efk_nodepool_node_count
  vnet_subnet_id        = azurerm_subnet.nodes.id
}
