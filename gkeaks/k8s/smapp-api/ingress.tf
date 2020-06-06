resource "kubernetes_secret" "smapp-api-tls-secret" {
  count = var.enabled && var.external_cert ? 1 : 0
  type  = "kubernetes.io/tls"

  metadata {
    name      = "smapp-api-tls-secret"
    namespace = var.namespace
  }

  data = {
    "tls.crt" = var.tls-cert
    "tls.key" = var.tls-key
  }
}

resource "kubernetes_ingress" "smapp-api_ingress" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "${var.app_name}-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"                 = "nginx"
      "kubernetes.io/tls-acme"                      = "true"
      "kubernetes.io/ingress.class"                 = "nginx"
      "ingress.kubernetes.io/ssl-redirect"          = "true"
      "ingress.kubernetes.io/force-ssl-redirect"    = "true"
      "nginx.org/websocket-services"                = "${var.app_name}-internal"
      "cert-manager.io/cluster-issuer"              = "letsencrypt-prod"
      "ingress.kubernetes.io/proxy-connect-timeout" = "600"
      "ingress.kubernetes.io/proxy-read-timeout"    = "600"
      "ingress.kubernetes.io/proxy-send-timeout"    = "600"
      "ingress.kubernetes.io/send-timeout"          = "600"
    }
  }

  spec {
    rule {
      host = "api.app.${var.domain}"
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
      hosts       = ["api.app.${var.domain}"]
      secret_name = "smapp-api-tls-secret"
    }
  }
}
