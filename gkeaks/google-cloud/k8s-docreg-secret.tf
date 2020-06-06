resource "kubernetes_secret" "docreg" {
  depends_on = [google_container_cluster.ak-core]
  metadata {
    name = "docreg"
  }

  data = {
    ".dockerconfigjson" = "${file("${path.module}/config.json")}"
  }

  type = "kubernetes.io/dockerconfigjson"
}
