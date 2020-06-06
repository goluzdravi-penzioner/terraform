resource "kubernetes_secret" "platform-tls-secret" {
  count = var.external_cert ? 1 : 0
  type  = "kubernetes.io/tls"

  metadata {
    name      = "platform-tls-secret"
    namespace = var.namespace
  }

  data = {
    "tls.crt" = var.platform-tls-cert
    "tls.key" = var.platform-tls-key
  }
}

resource "kubernetes_ingress" "platform_ingress" {
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
      host = "core.${var.domain}"
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
      hosts       = ["core.${var.domain}"]
      secret_name = "platform-tls-secret"
    }
  }
}
