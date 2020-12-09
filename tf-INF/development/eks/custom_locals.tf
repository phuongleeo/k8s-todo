locals {
  namespace = ["bootstrap", "monitoring", "argocd"]
}
locals {
  spot_instances = true
  bid_price      = "0.2"
}
locals {
  char_repository = {
    "stable"        = "https://charts.helm.sh/stable"
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
