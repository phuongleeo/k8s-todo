locals {
  common_tags = {
    "Project"     = var.project
    "Environment" = var.environment
    "Provisioner" = "Terraform"
  }

  eks_domain = var.domain_name
}

locals {
  availability_zones = formatlist("%s%s", data.aws_region.current.name, ["a", "b", "c"])
}

locals {
  cluster_name             = "${var.project}-${var.domain_env}"
  cas_service_account_name = "cluster-autoscaler-aws-cluster-autoscaler"
  external_dns_sa_name     = "external-dns"
  harbor_sa_name           = "harbor"
}


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
  }
}

locals {
  harbor_components = [
    "registry",
    "chartmuseum",
  ]
}

locals {
  whitelist_ips = [
    "42.119.112.110/32",
  ]
}
