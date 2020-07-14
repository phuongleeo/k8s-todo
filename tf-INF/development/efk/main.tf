terraform {
  backend "s3" {
    key = "stacks/efk"
  }
}

data "terraform_remote_state" "s3" {
  backend = "s3"

  config = {
    bucket = "${var.remote_state_bucket}"
    key    = "stacks/s3"
    region = "${var.aws_region}"
  }

  workspace = "${terraform.workspace}"
}

data "terraform_remote_state" "route53" {
  backend = "s3"

  config = {
    bucket = "${var.remote_state_bucket}"
    key    = "stacks/route53"
    region = "${var.aws_region}"
  }

  workspace = "${terraform.workspace}"
}

data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = "${var.remote_state_bucket}"
    key    = "stacks/eks"
    region = "${var.aws_region}"
  }

  workspace = "${terraform.workspace}"
}
