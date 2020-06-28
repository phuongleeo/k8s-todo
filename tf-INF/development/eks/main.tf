terraform {
  backend "s3" {
    key = "stacks/eks"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "${var.remote_state_bucket}"
    key    = "stacks/vpc"
    region = "${var.aws_region}"
  }

  workspace = "${terraform.workspace}"
}
data "terraform_remote_state" "key_pair" {
  backend = "s3"

  config = {
    bucket = "${var.remote_state_bucket}"
    key    = "stacks/key-pair"
    region = "${var.aws_region}"
  }

  workspace = "${terraform.workspace}"
}
data "terraform_remote_state" "ami" {
  backend = "s3"

  config = {
    bucket = "${var.remote_state_bucket}"
    key    = "stacks/ami"
    region = "${var.aws_region}"
  }

  workspace = "${terraform.workspace}"
}
data "terraform_remote_state" "secgroup" {
  backend = "s3"

  config = {
    bucket = "${var.remote_state_bucket}"
    key    = "stacks/sg"
    region = "${var.aws_region}"
  }

  workspace = "${terraform.workspace}"
}
