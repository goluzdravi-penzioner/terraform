resource "kubernetes_secret" "auth-service-tls-secret" {
  count = var.external_cert ? 1 : 0
  type  = "kubernetes.io/tls"

  metadata {
    name      = "auth-service-tls-secret"
    namespace = var.namespace
  }

  data = {
    "tls.crt" = var.auth-service-tls-cert
    "tls.key" = var.auth-service-tls-key
  }
}

resource "kubernetes_ingress" "auth_ingress" {
  metadata {
    name      = "${var.app_name}-auth-ingress"
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
      host = "auth.${var.domain}"
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
      hosts       = ["auth.${var.domain}"]
      secret_name = "auth-service-tls-secret"
    }
  }
}
