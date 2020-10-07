terraform {
  backend "s3" {
    key = "stacks/services"
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
