data "helm_repository" "keycloak" {
  name = "codecentric"
  url  = "https://codecentric.github.io/helm-charts"
}

resource "helm_release" "keycloak" {
  count      = var.keycloak ? 1 : 0
  repository = data.helm_repository.keycloak.metadata.0.name
  depends_on = [helm_release.certmanager]
  name       = "keycloak"
  chart      = "keycloak"
  namespace  = var.namespace

  set {
    name  = "keycloak.podLabels.env"
    value = var.cluster_name
  }
}

### Ingress and HTTPS ###
resource "kubernetes_ingress" "keycloak_ingress" {
  count = var.keycloak ? 1 : 0
  metadata {
    name      = "keycloak-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/tls-acme"               = "true"
      "kubernetes.io/ingress.class"          = "nginx"
      "cert-manager.io/cluster-issuer"       = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/affinity" = "cookie"
    }
  }

  spec {
    rule {
      host = "monitoring.${var.domain}"
      http {
        path {
          backend {
            service_name = "keycloak-http"
            service_port = 80
          }

          path = "/"
        }
      }
    }
  }
}
