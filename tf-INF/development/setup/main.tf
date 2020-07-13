terraform {
  backend "s3" {
    key = "stacks/setup"
  }
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
