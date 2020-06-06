resource "kubernetes_namespace" "logging" {
  count = var.efk ? 1 : 0
  metadata {
    name = "logging"
  }
}
###### Helm charts ######
data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "fluentd" {
  count      = var.efk ? 1 : 0
  repository = data.helm_repository.stable.metadata.0.name
  depends_on = [helm_release.certmanager]
  name       = "fluentd"
  chart      = "fluentd-elasticsearch"
  namespace  = "logging"

  set {
    name  = "elasticsearch.host"
    value = "elasticsearch-client.logging.svc"
  }
  set {
    name  = "elasticsearch.port"
    value = "9200"
  }
}

resource "helm_release" "kibana" {
  count      = var.efk ? 1 : 0
  repository = data.helm_repository.stable.metadata.0.name
  depends_on = [helm_release.certmanager]
  name       = "kibana"
  chart      = "kibana"
  namespace  = "logging"

  set {
    name  = "env.ELASTICSEARCH_HOSTS"
    value = "http://elasticsearch-client.logging.svc:9200"
  }
  set {
    name  = "service.externalPort"
    value = "5601"
  }
  set {
    name  = "dashboardImport.enabled"
    value = "true"
  }
}

resource "helm_release" "elasticsearch" {
  count      = var.efk ? 1 : 0
  repository = data.helm_repository.stable.metadata.0.name
  depends_on = [helm_release.certmanager]
  name       = "elasticsearch"
  chart      = "stable/elasticsearch"
  namespace  = "logging"
}
##### Kibana ingress #####

resource "kubernetes_ingress" "kibana_ingress" {
  count = var.efk ? 1 : 0
  metadata {
    name      = "kibana-ingress"
    namespace = "logging"
    annotations = {
      "kubernetes.io/tls-acme"               = "true"
      "kubernetes.io/ingress.class"          = "nginx"
      "cert-manager.io/cluster-issuer"       = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/affinity" = "cookie"
    }
  }

  spec {
    rule {
      host = "kibana.${var.domain}"
      http {
        path {
          backend {
            service_name = "kibana"
            service_port = "5601"
          }

          path = "/"
        }
      }
    }
  }
}
