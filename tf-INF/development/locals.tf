locals {
  common_tags = {
    "Project"     = var.project
    "Environment" = var.environment
    "Provisioner" = "Terraform"
  }

  domain     = "${var.domain_env}.new-${var.squad}.ryte.tech"
  eks_domain = "eks.${local.domain}"
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
