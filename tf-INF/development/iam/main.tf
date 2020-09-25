terraform {
  backend "s3" {
    key = "stacks/iam"
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
