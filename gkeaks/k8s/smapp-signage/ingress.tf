resource "kubernetes_secret" "smapp-signage-tls-secret" {
  count = var.enabled && var.external_cert ? 1 : 0
  type  = "kubernetes.io/tls"

  metadata {
    name      = "smapp-signage-tls-secret"
    namespace = var.namespace
  }

  data = {
    "tls.crt" = var.tls-cert
    "tls.key" = var.tls-key
  }
}

resource "kubernetes_ingress" "smapp-signage_ingress" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "${var.app_name}-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/tls-acme"                         = "true"
      "kubernetes.io/ingress.class"                    = "nginx"
      "cert-manager.io/cluster-issuer"                 = "letsencrypt-prod"
      "nginx.org/websocket-services"                   = "api-gateway-internal"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "3600"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "3600"
      "ingress.kubernetes.io/ssl-redirect"             = "true"
      "ingress.kubernetes.io/force-ssl-redirect"       = "true"
    }
  }

  spec {
    rule {
      host = "signage.${var.domain}"
      http {
        path {
          backend {
            service_name = "${var.app_name}-internal"
            service_port = 80
          }

          path = "/"
        }
      }
    }
    rule {
      host = "*.signage.${var.domain}"
      http {
        path {
          backend {
            service_name = "${var.app_name}-internal"
            service_port = 80
          }

          path = "/"
        }
      }
    }

    tls {
      hosts       = ["signage.${var.domain}"]
      secret_name = "smapp-signage-tls-secret"
    }
    tls {
      hosts       = ["*.signage.${var.domain}"]
      secret_name = "smapp-signage-wildcard-tls-secret"
    }
  }
}

