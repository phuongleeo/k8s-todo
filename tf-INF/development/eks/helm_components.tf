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
  version    = "0.16.0"
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
  repository = local.char_repository["autoscaler"]
  chart      = "cluster-autoscaler"
  version    = "9.10.9"
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
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
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
  name       = "external-dns"
  repository = local.char_repository["bitnami"]
  chart      = "external-dns"
  version    = "6.0.2"
  namespace  = kubernetes_namespace.bootstrap.metadata.0.name
  lint       = false
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
    value = "{service,ingress}"
  }
  set {
    name  = "domainFilters"
    value = "{${var.domain_name}}"
  }
  set {
    name  = "zoneIdFilters"
    value = "{${data.terraform_remote_state.route53.outputs.zone_id}}"
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
    value = "external-dns.alpha.kubernetes.io=enable"
  }
  set {
    name  = "interval"
    value = "1m"
  }
}

resource "helm_release" "nginx_ingress" {
  count = local.enable_ingress_nginx ? 1 : 0
  depends_on = [
    module.eks,
    null_resource.install_istio
  ]
  name       = "nginx-ingress"
  repository = local.char_repository["ingress-nginx"]
  chart      = "ingress-nginx"
  version    = "3.40.0"
  namespace  = "bootstrap"
  lint       = true
  wait       = false
  set {
    name  = "controller.replicaCount"
    value = 1
  }
  set {
    name  = "controller.ingressClassResource.name"
    value = "nginx"
  }
  set {
    name  = "controller.ingressClassResource.controllerValue"
    value = "k8s.io/nginx-ingress"
  }
  set {
    name  = "controller.ingressClassResource.enabled"
    value = "true"
    type  = "string"
  }
  set {
    name  = "controller.ingressClassByName"
    value = "true"
    type  = "string"
  }
  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Cluster"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-proxy-protocol"
    value = "*"
  }
  set {
    name  = "controller.config.proxy-real-ip-cidr"
    value = var.cidr_v4
    type  = "string"
  }
  set {
    name  = "controller.config.use-proxy-protocol"
    value = "true"
    type  = "string"
  }
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
    value = "tcp" # Switch to "http" when externalTrafficPolicy is set to "Local"
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
  //expose metrics
  set {
    name  = "controller.metrics.enabled"
    value = "true"
    type  = "string"
  }
  set {
    name  = "controller.metrics.service.annotations.prometheus\\.io/scrape"
    value = "true"
    type  = "string"
  }
  set {
    name  = "controller.metrics.service.annotations.prometheus\\.io/port"
    value = 10254
    type  = "string"
  }
}
//EFS driver
resource "helm_release" "efs_csi" {
  depends_on = [
    module.eks,
    null_resource.install_istio
  ]
  name       = "efs-csi"
  repository = local.char_repository["efs-csi"]
  chart      = "aws-efs-csi-driver"
  version    = "0.1.0"
  namespace  = "kube-system"
  lint       = true
  wait       = false
}
//metrics server
resource "helm_release" "metrics_server" {
  depends_on = [
    module.eks,
  ]
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.7.0"
  namespace  = "kube-system"
  lint       = false
  wait       = false
  set {
    name  = "args[0]"
    value = "--kubelet-preferred-address-types=InternalIP"
    type  = "string"
  }
  set {
    name  = "rbac.create"
    value = true
  }
}
resource "helm_release" "kubernetes_dashboard" {
  depends_on = [
    module.eks,
  ]
  name       = "kubernetes-dashboard"
  repository = "https://kubernetes.github.io/dashboard/"
  chart      = "kubernetes-dashboard"
  version    = "5.0.5"
  namespace  = kubernetes_namespace.dashboard.metadata.0.name
  lint       = false
  wait       = false
  set {
    name  = "rbac.create"
    value = "true"
  }
  set {
    name  = "rbac.clusterReadOnlyRole"
    value = "true"
  }
  set {
    name  = "ingress.enabled"
    value = "true"
  }
  set {
    name  = "ingress.hosts"
    type  = "string"
    value = "{k8s-dashboard.${var.domain_env}.${var.domain_name}}"
  }
  set {
    name  = "ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "internal-nginx"
  }
  set {
    name  = "ingress.className"
    value = "internal-nginx"
  }
  set {
    name  = "ingress.annotations.external-dns\\.alpha\\.kubernetes\\.io"
    value = "enable"
  }
  set {
    name  = "settings.clusterName"
    value = local.cluster_name
  }
  set {
    name  = "settings.itemsPerPage"
    value = 20
  }
  set {
    name  = "metricsScraper.enabled"
    value = "true"
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.dashboard.metadata.0.name
  }
}