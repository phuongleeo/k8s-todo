terraform {
  backend "s3" {
    key = "stacks/eks"
  }
}


data "terraform_remote_state" "s3" {
  backend = "s3"

  config = {
    bucket = "${var.remote_state_bucket}"
    key    = "stacks/s3"
    region = "${var.aws_region}"
  }

  workspace = terraform.workspace
}

data "terraform_remote_state" "route53" {
  backend = "s3"

  config = {
    bucket = "${var.remote_state_bucket}"
    key    = "stacks/route53"
    region = "${var.aws_region}"
  }

  workspace = terraform.workspace
}
data "terraform_remote_state" "setup" {
  backend = "s3"

  config = {
    bucket = "${var.remote_state_bucket}"
    key    = "stacks/setup"
    region = "${var.aws_region}"
  }

  workspace = terraform.workspace
}
data "terraform_remote_state" "iam" {
  backend = "s3"

  config = {
    bucket = "${var.remote_state_bucket}"
    key    = "stacks/iam"
    region = "${var.aws_region}"
  }

  workspace = terraform.workspace
}
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "${var.remote_state_bucket}"
    key    = "stacks/vpc"
    region = "${var.aws_region}"
  }

  workspace = terraform.workspace
}

data "terraform_remote_state" "key_pair" {
  backend = "s3"

  config = {
    bucket = "${var.remote_state_bucket}"
    key    = "stacks/key-pair"
    region = "${var.aws_region}"
  }

  workspace = terraform.workspace
}