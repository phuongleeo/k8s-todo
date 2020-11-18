locals {
  namespace = ["bootstrap", "monitoring"]
}

locals {
  char_repository = {
    "stable"        = "https://kubernetes-charts.storage.googleapis.com"
    "eks"           = "https://aws.github.io/eks-charts"
    "harbor"        = "https://helm.goharbor.io"
    "bitnami"       = "https://charts.bitnami.com/bitnami"
    "datawire"      = "https://www.getambassador.io"
    "incubator"     = "https://kubernetes-charts-incubator.storage.googleapis.com"
    "argocd"        = "https://argoproj.github.io/argo-helm"
    "cloudposse"    = "https://charts.cloudposse.com/incubator/"
    "ingress-nginx" = "https://kubernetes.github.io/ingress-nginx"
    "center"        = "https://repo.chartcenter.io"
    "efs-csi"       = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  }
}

locals {
  harbor_components = [
    "registry",
    "chartmuseum",
  ]
}
