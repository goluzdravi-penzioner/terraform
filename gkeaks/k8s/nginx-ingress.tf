#https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/

#TODO for the move
#in infra: 
#terraform state rm kubernetes_namespace.nginx
#terraform state rm helm_release.nginx-ingress
#in k8s: terraform import helm_release.nginx-ingress nginx/nginx-ingress-akenza-dev
#in k8s: terraform import kubernetes_namespace.nginx nginx
resource "kubernetes_namespace" "nginx-udp" {
  metadata {
    name = "nginx-udp"
  }
}

resource "kubernetes_namespace" "nginx" {
  metadata {
    name = "nginx"
  }
}

data "helm_repository" "nginx" {
  name = "nginxinc"
  url  = "https://helm.nginx.com/stable"
}

resource "helm_release" "nginx-ingress" {
  repository = data.helm_repository.nginx.metadata[0].url
  name       = "nginx-ingress-${var.cluster_name}"
  chart      = "nginx-ingress"
  namespace  = kubernetes_namespace.nginx.metadata[0].name
  values = [
    file("nginx-values.yaml")
  ]
  timeout = 600
}

resource "helm_release" "nginx-ingress-udp" {
  depends_on = [helm_release.nginx-ingress]
  repository = data.helm_repository.nginx.metadata[0].url
  name       = "nginx-ingress-udp-${var.cluster_name}"
  chart      = "nginx-ingress"
  skip_crds  = true
  namespace  = kubernetes_namespace.nginx-udp.metadata[0].name
  values = [
    file("nginx-udp-values.yaml")
  ]
  timeout = 600
}
