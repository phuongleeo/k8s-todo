data "template_file" "harbor_registry_patch" {
  template = file("files/patch-harbor-registry-service.yaml")
  vars = {
    accesskey         = data.terraform_remote_state.iam.outputs.harbor_access_key
    secretkey         = data.terraform_remote_state.iam.outputs.harbor_secret_key
    aws_region        = var.aws_region
    imagechart_bucket = data.terraform_remote_state.s3.outputs.chart_name
  }
}

# //gohabor https://goharbor.io/docs/2.0.0/install-config/harbor-ha-helm/
# //chart: https://hub.helm.sh/charts/harbor/harbor
resource "helm_release" "goharbor" {
  count = var.harbor_enable ? 1 : 0
  depends_on = [
    module.eks,
    null_resource.install_istio
  ]
  name       = "harbor"
  repository = local.char_repository["harbor"]
  chart      = "harbor"
  version    = "1.4.2" //harbor chart version: 1.4.2
  namespace  = kubernetes_namespace.bootstrap.metadata.0.name
  lint       = true
  wait       = false
  //Ingress
  set {
    name  = "expose.type"
    value = "ingress" //clusterIP
  }
  set {
    name  = "expose.tls.enabled"
    value = false
  }
  set {
    name  = "externalURL"
    value = "https://harbor.${local.eks_domain}"
  }
  set {
    name  = "expose.ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "%{if var.ingress_nginx}nginx%{else}istio%{endif}"
  }
  set {
    name  = "expose.ingress.annotations.external-dns"
    value = "enable"
  }
  set {
    name  = "expose.ingress.hosts.core"
    value = "harbor.${local.eks_domain}"
  }
  set {
    name  = "expose.ingress.hosts.notary"
    value = "notary.${local.eks_domain}"
  }
  //End
  set {
    name  = "notary.enabled"
    value = true
  }
  //Vulnerability Scanning
  set {
    name  = "clair.enabled"
    value = true
  }
  set {
    name  = "trivy.enabled"
    value = false //I personaly prefer clair
  }
  //End
  set {
    name  = "registry.credentials.username"
    value = "harbor_registry_user"
  }
  set {
    name  = "registry.credentials.password"
    value = "harbor_registry_password"
  }
  set {
    name  = "registry.relativeurls"
    value = "true"
  }
  set {
    name  = "harborAdminPassword"
    value = "admin"
  }
  //Persistence volume
  set {
    name  = "persistence.enabled"
    value = true
  }
  set {
    name  = "persistence.resourcePolicy"
    value = "delete"
  }
  set {
    //issue: https://github.com/goharbor/harbor-helm/pull/624, the next release 1.5.0 will fix this issue
    //update chartmuseum configmap to get rid of this
    name  = "persistence.imageChartStorage.type"
    value = "s3" //filesystem
  }
  set {
    name  = "persistence.imageChartStorage.disableredirect"
    value = true
  }
  set {
    name  = "persistence.imageChartStorage.s3.bucket"
    value = data.terraform_remote_state.s3.outputs.chart_name
  }
  set {
    name  = "persistence.imageChartStorage.s3.region"
    value = var.aws_region
  }
  set {
    name  = "persistence.imageChartStorage.s3.rootdirectory"
    value = "harbor"
  }
  set {
    name  = "persistence.persistentVolumeClaim.database.size"
    value = "1Gi"
  }
  //End pv
  //Service account
  dynamic "set" {
    for_each = local.harbor_components
    content {
      name  = "${set.value}.serviceAccountName"
      value = kubernetes_service_account.harbor.metadata.0.name
    }
  }
  //End sa
  provisioner "local-exec" {
    //fix database postgres user permission https://github.com/goharbor/harbor/issues/8224;https://github.com/goharbor/harbor-helm/issues/725
    command = <<EOF
          kubectl patch -n ${kubernetes_namespace.bootstrap.metadata.0.name} sts harbor-harbor-database --patch '${file("files/patch-harbor-init-container.yaml")}' --record;
          kubectl patch -n ${kubernetes_namespace.bootstrap.metadata.0.name} cm harbor-harbor-chartmuseum --type='json' -p='[{"op": "add", "path": "/data/AWS_SDK_LOAD_CONFIG", "value": "1"}]' --record;
          kubectl rollout restart -n ${kubernetes_namespace.bootstrap.metadata.0.name} deploy/harbor-harbor-chartmuseum;
          kubectl patch -n ${kubernetes_namespace.bootstrap.metadata.0.name} cm harbor-harbor-registry --patch '${data.template_file.harbor_registry_patch.rendered}' --record;
          kubectl rollout restart -n ${kubernetes_namespace.bootstrap.metadata.0.name} deploy/harbor-harbor-registry
EOF
    environment = {
      KUBECONFIG = pathexpand("${path.cwd}/kubeconfig_${local.cluster_name}")
    }
  }
}
