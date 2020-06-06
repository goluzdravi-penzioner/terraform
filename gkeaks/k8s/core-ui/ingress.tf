resource "kubernetes_secret" "core-ui-tls-secret" {
  count = var.external_cert ? 1 : 0
  type  = "kubernetes.io/tls"

  metadata {
    name      = "core-ui-tls-secret"
    namespace = var.namespace
  }

  data = {
    "tls.crt" = var.core-ui-tls-cert
    "tls.key" = var.core-ui-tls-key
  }
}

resource "kubernetes_ingress" "core-ui_ingress" {
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
    }
  }

  spec {
    rule {
      host = "preview.core.${var.domain}"
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
      hosts       = ["preview.core.${var.domain}"]
      secret_name = "core-ui-tls-secret"
    }
  }
}
