provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.production.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.production.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.production.token
    load_config_file       = false
  }
  version = "~> 1.0"
}

//prometheus-operator https://github.com/helm/charts/tree/master/stable/prometheus-operator
resource "helm_release" "prometheus" {
  name       = "prometheus-operator"
  repository = lookup(local.char_repository, "stable")
  chart      = "prometheus-operator"
  version    = "8.15.11"
  namespace  = kubernetes_namespace.monitoring.metadata.0.name
  lint       = true
}

//https://github.com/aws/eks-charts/tree/master/stable/aws-node-termination-handler
resource "helm_release" "node_termination_handler" {
  name       = "aws-node-termination-handler"
  repository = lookup(local.char_repository, "eks")
  chart      = "aws-node-termination-handler"
  version    = "0.8.0"
  namespace  = "kube-system"
  lint       = true

  set {
    name  = "enablePrometheusServer"
    value = "true"
  }
  set {
    name  = "enableSpotInterruptionDraining"
    value = "true"
  }
  set {
    name  = "nodeSelector.node\\.kubernetes\\.io/lifecycle"
    value = "spot"
  }
}

//gohabor https://goharbor.io/docs/2.0.0/install-config/harbor-ha-helm/
resource "helm_release" "goharbor" {
  name       = "harbor"
  repository = lookup(local.char_repository, "harbor")
  chart      = "harbor"
  version    = "1.4.1"
  namespace  = kubernetes_namespace.bootstrap.metadata.0.name
  lint       = true
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = lookup(local.char_repository, "binami")
  chart      = "external-dns"
  version    = "3.2.3"
  namespace  = kubernetes_namespace.bootstrap.metadata.0.name
  lint       = true
  set {
    name  = "provider"
    value = "aws"
  }
  set {
    name  = "aws.assumeRoleArn"
    value = ""
  }
}
