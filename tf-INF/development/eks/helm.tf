provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.eks.token
    load_config_file       = false
  }
  version = "~> 1.0"
}

//prometheus-operator https://github.com/helm/charts/tree/master/stable/prometheus-operator
resource "helm_release" "prometheus" {
  depends_on = [
    module.eks,
    null_resource.install_istio
  ]
  name       = "prometheus-operator"
  repository = lookup(local.char_repository, "stable")
  chart      = "prometheus-operator"
  version    = "8.15.11"
  namespace  = kubernetes_namespace.monitoring.metadata.0.name
  lint       = true
}

//https://github.com/aws/eks-charts/tree/master/stable/aws-node-termination-handler
resource "helm_release" "node_termination_handler" {
  depends_on = [
    module.eks,
    null_resource.install_istio
  ]
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

resource "helm_release" "cluster_autoscaler" {
  depends_on = [
    module.eks,
    null_resource.install_istio
  ]
  name       = "cluster-autoscaler"
  repository = lookup(local.char_repository, "stable")
  chart      = "cluster-autoscaler"
  version    = "7.3.4"
  namespace  = "kube-system"
  lint       = true
  set {
    name  = "autoDiscovery.enabled"
    value = true
  }
  set {
    name  = "autoDiscovery.clusterName"
    value = local.cluster_name
  }
  set {
    name  = "awsRegion"
    value = var.aws_region
  }

  set {
    name  = "rbac.serviceAccountAnnotations.eks\\.amazonaws\\.com/role-arn"
    value = module.cluster_autoscaler.this_iam_role_arn
  }
  set {
    name  = "cloudProvider"
    value = "aws"
  }
  set {
    name  = "serviceMonitor.enabled"
    value = true
  }
}
//gohabor https://goharbor.io/docs/2.0.0/install-config/harbor-ha-helm/

resource "helm_release" "goharbor" {
  depends_on = [
    module.eks,
    null_resource.install_istio
  ]
  name       = "harbor"
  repository = lookup(local.char_repository, "harbor")
  chart      = "harbor"
  version    = "1.4.1" //harbor chart version: 1.4.1 , bitnami: 6.0.10
  namespace  = kubernetes_namespace.bootstrap.metadata.0.name
  lint       = true
  set {
    name  = "expose.ingress.hosts.core" // key goharbor chart
    value = "harbor.${local.eks_domain}"
    # name  = "ingress.hosts.core" // bitnami key
    # value = "harbor-core.${local.eks_domain}"
  }
  set {
    name = "expose.ingress.hosts.notary"
    # name  = "ingress.hosts.notary"
    value = "notary.${local.eks_domain}"
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
    value = "admin"
  }
  set {
    name  = "persistence.imageChartStorage.type"
    value = "filesystem"
  }
  set {
    name  = "persistence.resourcePolicy"
    value = "delete"
  }
  set {
    name  = "persistence.persistentVolumeClaim.registry.size"
    value = "1Gi"
  }
  set {
    name  = "persistence.persistentVolumeClaim.chartmuseum.size"
    value = "1Gi"
  }
  # set {
  #   name  = "persistence.imageChartStorage.s3.bucket"
  #   value = data.terraform_remote_state.s3.outputs.chart_name
  # }
  # set {
  #   name  = "persistence.imageChartStorage.s3.region"
  #   value = var.aws_region
  # }

  set {
    name  = "expose.type"
    value = "ingress"
  }
  set {
    name  = "expose.ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "istio"
  }
  set {
    name  = "expose.ingress.annotations.external-dns/enable"
    value = "\"true\""
  }

  set {
    name  = "externalURL"
    value = "https://harbor.${local.eks_domain}"
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
  depends_on = [
    module.eks,
    null_resource.install_istio
  ]
  name       = "external-dns"
  repository = lookup(local.char_repository, "bitnami")
  chart      = "external-dns"
  version    = "3.2.4"
  namespace  = kubernetes_namespace.bootstrap.metadata.0.name
  lint       = true

  # values = [
  #   # data.template_file.external_dns.rendered
  #   templatefile("files/external-dns.yaml", {
  #     eks_domain        = local.eks_domain,
  #     eks_zone_id       = data.terraform_remote_state.route53.outputs.eks_zone_id,
  #     external_dns_role = aws_iam_role.external_dns.arn
  #   })
  # ]
  set {
    name  = "provider"
    value = "aws"
  }
  set {
    name  = "aws.region"
    value = var.aws_region
  }
  set {
    name  = "aws.zoneType"
    value = "public"
  }
  set {
    name  = "sources"
    value = "{service,ingress}"
  }
  set {
    name  = "domainFilters"
    value = "{${local.eks_domain}}"
  }
  set {
    name  = "zoneIdFilters"
    value = "{${data.terraform_remote_state.route53.outputs.eks_zone_id}}"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.external_dns_role.this_iam_role_arn
  }
  set {
    name  = "serviceAccount.name"
    value = "external-dns"
  }
  set {
    name  = "rbac.create"
    value = true
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
  set {
    name  = "annotationFilter"
    value = "external-dns/enable=true"
  }
}

//Argo CI/CD
# resource "helm_release" "argo_workflows" {
#   name       = "argo-workflows"
#   repository = lookup(local.char_repository, "argocd")
#   chart      = "argo"
#   version    = "0.9.8"
#   namespace  = kubernetes_namespace.bootstrap.metadata.0.name
#   lint       = true
#
#   values = [
#     # data.template_file.external_dns.rendered
#     yamlencode({ "controller" : { "workflowNamespaces" : [
#       kubernetes_namespace.bootstrap.metadata.0.name,
#       kubernetes_namespace.monitoring.metadata.0.name,
#     "api"] } })
#   ]
# }
# resource "helm_release" "argo-cd" {
#   name       = "argo-cd"
#   repository = lookup(local.char_repository, "argocd")
#   chart      = "argo-cd"
#   version    = "2.5.4"
#   namespace  = kubernetes_namespace.bootstrap.metadata.0.name
#   lint       = true
# }
# resource "helm_release" "argo_events" {
#   name       = "argo-events"
#   repository = lookup(local.char_repository, "argocd")
#   chart      = "argo-events"
#   version    = "0.14.0"
#   namespace  = kubernetes_namespace.bootstrap.metadata.0.name
#   lint       = true
#   values = [
#     templatefile("files/argo.yaml", {
# namespace = kubernetes_namespace.bootstrap.metadata.0.name
#     })
#   ]
# }
# resource "helm_release" "argo_rollouts" {
#   name       = "argo-rollouts"
#   repository = lookup(local.char_repository, "argocd")
#   chart      = "argo-rollouts"
#   version    = "0.3.2"
#   namespace  = kubernetes_namespace.bootstrap.metadata.0.name
#   lint       = true
# }
# resource "helm_release" "argocd_notifications" {
#   name       = "argocd-notifications"
#   repository = lookup(local.char_repository, "argocd")
#   chart      = "argocd-notifications"
#   version    = "1.0.7"
#   namespace  = kubernetes_namespace.bootstrap.metadata.0.name
#   lint       = true
# }
