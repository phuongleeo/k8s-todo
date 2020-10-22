terraform {
  backend "s3" {
    key = "stacks/storages"
  }
}

data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket
    key    = "stacks/eks"
    region = var.aws_region
  }

  workspace = terraform.workspace
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket
    key    = "stacks/vpc"
    region = var.aws_region
  }

  workspace = terraform.workspace
}
