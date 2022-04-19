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
  enable_ingress_istio   = false
  enable_ingress_nginx   = true
  harbor_enable          = false
  enable_jx              = true
  enable_atlantis        = false
  enable_datadog         = false
  enable_vault           = true
  k8s_efs_driver         = "efs.csi.aws.com"
  quay_registry_server   = "quay.io"
  github_registry_server = "docker.pkg.github.com"
}
