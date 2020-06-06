# Also refer to
#   https://github.com/helm/charts/tree/master/stable/prometheus-operator
#   https://github.com/coreos/prometheus-operator/blob/master/Documentation/user-guides/running-exporters.md
#   https://github.com/helm/charts/blob/master/stable/prometheus-operator/values.yaml
#   https://github.com/helm/charts/tree/master/stable/prometheus-operator#prometheus-operator
#   https://github.com/coreos/prometheus-operator/blob/master/Documentation/design.md

resource "kubernetes_namespace" "metrics" {
  metadata {
    name = "metrics"
  }
}

data "helm_repository" "stable2" {
  name = "stable2"
  url  = "https://kubernetes-charts.storage.googleapis.com/"
}

resource "helm_release" "prometheus" {
  count           = var.prometheus ? 1 : 0
  name            = "prometheus-operator"
  chart           = "prometheus-operator"
  repository      = data.helm_repository.stable2.metadata[0].url
  namespace       = kubernetes_namespace.metrics.metadata[0].name

  values = [
    file("prometheus-values.yaml")
  ]

  set {
    name  = "podLabels.env"
    value = var.cluster_name
  }
}

#TODO handle Running on private GKE clusters
