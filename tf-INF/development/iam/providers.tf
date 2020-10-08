provider "aws" {
  allowed_account_ids = [var.aws_account]

  region  = var.aws_region
  version = "~> 2.40"
}

data "aws_region" "current" {
}