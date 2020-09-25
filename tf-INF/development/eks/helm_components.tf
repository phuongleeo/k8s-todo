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
  repository = local.char_repository["stable"]
  chart      = "prometheus-operator"
  version    = "8.15.11"
  namespace  = kubernetes_namespace.monitoring.metadata.0.name
  lint       = true
  wait       = false
}

//https://github.com/aws/eks-charts/tree/master/stable/aws-node-termination-handler
resource "helm_release" "node_termination_handler" {
  depends_on = [
    module.eks,
    null_resource.install_istio
  ]
  name       = "aws-node-termination-handler"
  repository = local.char_repository["eks"]
  chart      = "aws-node-termination-handler"
  version    = "0.8.0"
  namespace  = "kube-system"
  lint       = true
  wait       = false

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
  repository = local.char_repository["stable"]
  chart      = "cluster-autoscaler"
  version    = "7.3.4"
  namespace  = "kube-system"
  lint       = true
  wait       = false
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
  //Scale policy
  set {
    //https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-are-expanders
    name  = "extraArgs.expander"
    value = "random"
  }
  set {
    name  = "extraArgs.scale-down-enabled"
    value = true
  }
}

//https://hub.helm.sh/charts/bitnami/external-ds
resource "helm_release" "external_dns" {
  depends_on = [
    module.eks,
    null_resource.install_istio
  ]
  name       = "external-dn"
  repository = local.char_repository["bitnami"]
  chart      = "external-dns"
  version    = "3.2.4"
  namespace  = kubernetes_namespace.bootstrap.metadata.0.name
  lint       = true
  wait       = false

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
    value = "{service,ingress,istio-gateway}"
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
    value = local.external_dns_sa_name
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
    value = "external-dns=enable"
  }
  set {
    name  = "interval"
    value = "1m"
  }
}

resource "helm_release" "nginx_ingress" {
  count = var.ingress_nginx ? 1 : 0
  depends_on = [
    module.eks,
    null_resource.install_istio
  ]
  name       = "nginx-ingress"
  repository = local.char_repository["ingress-nginx"]
  chart      = "ingress-nginx"
  version    = "2.15.0"
  namespace  = "bootstrap"
  lint       = true
  wait       = false

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"
    value = data.terraform_remote_state.setup.outputs.cert_arn
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-cross-zone-load-balancing-enabled"
    value = "true"
    type  = "string"
  }
  set {
    name  = "controller.service.annotations.service\\.kubernetes\\.io/load-balancer-cleanup"
    value = "true"
    type  = "string"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-backend-protocol"
    value = "http"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-ports"
    value = "https"
  }
  set {
    name  = "controller.service.targetPorts.http"
    value = "http"
  }
  set {
    name  = "controller.service.targetPorts.https"
    value = "http"
  }
}
