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
  cluster_name = "${var.project}-${var.domain_env}"
}

