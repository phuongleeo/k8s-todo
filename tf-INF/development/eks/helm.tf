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
  set {
    name  = "expose.ingress.hosts.core"
    value = "harbor-core.${local.eks_domain}"
  }
  set {
    name  = "expose.ingress.hosts.notary"
    value = "harbor-notary.${local.eks_domain}"
  }

  set {
    name  = "registry.credentials.username"
    value = "harbor_registry_user"
  }
  set {
    name  = "registry.credentials.password"
    value = "harbor_registry_password"
  }
  set {
    name  = "harborAdminPassword"
    value = "Harbor12345"
  }
  set {
    name  = "persistence.imageChartStorage.type"
    value = "s3"
  }
  set {
    name  = "persistence.imageChartStorage.s3.bucket"
    value = data.terraform_remote_state.s3.outputs.chart_name
  }
  # set {
  #   name  = "persistence.persistentVolumeClaim.registry.storageClass"
  #   value = "s3"
  # }
  # set {
  #   name  = "persistence.persistentVolumeClaim.chartmuseum.storageClass"
  #   value = "s3"
  # }
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
    value = aws_iam_role.external_dns.arn
  }
  set {
    name  = "domainFilters"
    value = local.eks_domain
  }
  set {
    name  = "zoneIdFilters"
    value = data.terraform_remote_state.route53.outputs.eks_zone_id
  }
  set {
    name  = "aws.zoneType"
    value = "public"
  }
  set {
    name  = "sources"
    value = ["service", "ingress"]
  }
  //For ExternalDNS to be able to read Kubernetes and AWS token files
  set {
    name  = "podSecurityContext.fsGroup"
    value = "65534"
  }
  //would prevent ExternalDNS from deleting any records, options: sync, upsert-only
  set {
    name  = "policy"
    value = "upsert-only"
  }
}
