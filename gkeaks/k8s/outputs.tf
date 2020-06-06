data "kubernetes_service" "ingress" {
  depends_on = [helm_release.nginx-ingress]
  metadata {
    name      = "nginx-ingress-${var.cluster_name}-nginx-ingress"
    namespace = "nginx"
  }
}

data "kubernetes_service" "ingress-udp" {
  depends_on = [helm_release.nginx-ingress-udp]
  metadata {
    name      = "nginx-ingress-udp-${var.cluster_name}-nginx-ingress"
    namespace = "nginx-udp"
  }
}

output "loadbalancer_ip" {
  value = data.kubernetes_service.ingress.load_balancer_ingress.0.ip
}

output "loadbalancer_ip_udp" {
  value = data.kubernetes_service.ingress-udp.load_balancer_ingress.0.ip
}
