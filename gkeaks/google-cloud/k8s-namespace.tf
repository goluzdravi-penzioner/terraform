resource "kubernetes_namespace" "ak-core" {
  depends_on = [google_container_cluster.ak-core, google_container_node_pool.primary_nodes]
  metadata {
    name = var.namespace
  }
}
