resource "kubernetes_secret" "docreg" {
  metadata {
    name      = "docreg"
    namespace = var.namespace
  }

  data = {
    ".dockerconfigjson" = "${file("${path.module}/config.json")}"
  }

  type = "kubernetes.io/dockerconfigjson"
}
