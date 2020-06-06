#refer to https://github.com/jaegertracing/helm-charts/tree/master/charts/jaeger-operator#installing-the-chart 
resource "kubernetes_namespace" "jaeger_namespace" {
  metadata {
    name = "jaeger"
  }
}

data "helm_repository" "jaeger_repository" {
  name = "jaegertracing"
  url  = "https://jaegertracing.github.io/helm-charts"
}

resource "helm_release" "jaeger" {
  count      = var.jaeger ? 1 : 0
  name       = "jaeger-operator"
  chart      = "jaeger-operator"
  repository = data.helm_repository.jaeger_repository.url
  namespace  = kubernetes_namespace.jaeger_namespace.metadata[0].name

  values = [
    file("jaeger-values.yaml")
  ]
}
