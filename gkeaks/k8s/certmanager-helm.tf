#https://cert-manager.io/docs/configuration/acme/
data "helm_repository" "certmanager" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

data "template_file" "kubeconfig" {
  count    = var.cert_manager ? 1 : 0
  template = file("${path.module}/gke_kubeconfig-template.yaml")

  vars = {
    cluster_name    = data.terraform_remote_state.infrastructure_state.outputs.kube_config.name
    endpoint        = data.terraform_remote_state.infrastructure_state.outputs.kube_config.endpoint
    user_name       = data.terraform_remote_state.infrastructure_state.outputs.kube_config.master_auth.0.username
    user_password   = data.terraform_remote_state.infrastructure_state.outputs.kube_config.master_auth.0.password
    cluster_ca      = data.terraform_remote_state.infrastructure_state.outputs.kube_config.master_auth.0.cluster_ca_certificate
    client_cert     = data.terraform_remote_state.infrastructure_state.outputs.kube_config.master_auth.0.client_certificate
    client_cert_key = data.terraform_remote_state.infrastructure_state.outputs.kube_config.master_auth.0.client_key
  }
}

resource "local_file" "kubeconfiggke" {
  count    = var.cert_manager ? 1 : 0
  content  = data.template_file.kubeconfig.0.rendered
  filename = "${path.module}/kubeconfig_gke"
}

data "template_file" "clusterissuer" {
  count    = var.cert_manager ? 1 : 0
  template = file("${path.module}/clusterissuer-template.yaml")

  vars = {
    cloudflare_apikey = var.cloudflare_apikey
  }
}

resource "local_file" "clusterissuer" {
  count    = var.cert_manager ? 1 : 0
  content  = data.template_file.clusterissuer.0.rendered
  filename = "${path.module}/clusterissuer.yaml"
}

resource "null_resource" "certmanager-preinstall" {
  depends_on = [local_file.kubeconfiggke, local_file.clusterissuer]
  count      = var.cert_manager ? 1 : 0
  provisioner "local-exec" {
    command = <<EOF
    export KUBECONFIG=${path.module}/kubeconfig_gke 
    curl -sLO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
    chmod +x kubectl
    ./kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.14.2/cert-manager.crds.yaml
    ./kubectl create namespace cert-manager
    ./kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true
    ./kubectl apply -f clusterissuer.yaml
    EOF
  }
}

#https://hub.helm.sh/charts/jetstack/cert-manager
resource "helm_release" "certmanager" {
  count      = var.cert_manager ? 1 : 0
  depends_on = [null_resource.certmanager-preinstall]

  repository      = data.helm_repository.certmanager.metadata.0.url
  name            = "cert-manager"
  chart           = "cert-manager"
  namespace       = "cert-manager"
  version         = "v0.14.2"
  skip_crds       = true
  cleanup_on_fail = true

  set {
    name  = "ingressShim.defaultIssuerName"
    value = "letsencrypt-prod"
  }
  set {
    name  = "ingressShim.defaultIssuerKind"
    value = "ClusterIssuer"
  }

  set {
    name  = "podLabels.env"
    value = var.cluster_name
  }
}

#TODO create wildcard certificates to prevent rate-limiting issue
