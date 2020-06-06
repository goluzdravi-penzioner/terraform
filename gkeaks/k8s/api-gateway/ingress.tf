resource "kubernetes_secret" "api-gateway-tls-secret" {
  count = var.external_cert ? 1 : 0
  #https://pineknollconsulting.netlify.com/kubernetes-tls-secrets-in-terraform/
  #https://shocksolution.com/2018/12/14/creating-kubernetes-secrets-using-tls-ssl-as-an-example/
  type = "kubernetes.io/tls"

  metadata {
    name      = "api-gateway-tls-secret"
    namespace = var.namespace
  }

  data = {
    "tls.crt" = var.api-gateway-tls-cert
    "tls.key" = var.api-gateway-tls-key
  }
}

resource "kubernetes_ingress" "api-gateway_ingress" {
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
      host = "api.core.${var.domain}"
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
      hosts       = ["api.core.${var.domain}"]
      secret_name = "api-gateway-tls-secret"
    }
  }
}
