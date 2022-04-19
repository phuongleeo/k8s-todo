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
locals {
  api_key = jsondecode(data.aws_secretsmanager_secret_version.datadog_api_key.secret_string)["datadog_api_key"]
}

locals {
  app_key = jsondecode(data.aws_secretsmanager_secret_version.datadog_app_key.secret_string)["datadog_app_key"]
}

locals {
  # Whitelist Github source addresses: https://api.github.com/meta
  github_source_address = <<EOF
  192.30.252.0/22\,
  185.199.108.0/22\,
  140.82.112.0/20\,
  143.55.64.0/20\,
  13.230.158.120/32\,
  18.179.245.253/32\,
  52.69.239.207/32\,
  13.209.163.61/32\,
  54.180.75.25/32\,
  13.233.76.15/32\,
  13.234.168.60/32\,
  13.236.14.80/32\,
  13.238.54.232/32\,
  52.63.231.178/32\,
  20.201.28.148/32\,
  20.205.243.168/32\,
  102.133.202.248/32
EOF
}