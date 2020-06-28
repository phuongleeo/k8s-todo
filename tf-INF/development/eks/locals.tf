locals {
  common_tags = {
    "Project"     = var.project
    "Environment" = var.environment
    "Provisioner" = "Terraform"
  }

  domain = "${var.domain_env}.${var.project}.com"
}

locals {
  availability_zones = formatlist("%s%s", data.aws_region.current.name, ["a", "b", "c"])
}

locals {
  cluster_name = "${var.project}-${var.domain_env}"
}

