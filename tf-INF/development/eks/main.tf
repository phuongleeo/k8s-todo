terraform {
  backend "s3" {
    key = "stacks/eksv2"
  }
}

data "aws_vpc" "development" {
  cidr_block = var.cidr_v4
}
data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.development.id
  filter {
    name   = "tag:Name"
    values = ["development-subnet-private"]
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.development.id
  filter {
    name   = "tag:Name"
    values = ["development-subnet-public"]
  }
}

data "aws_subnet" "cidr_public" {
  for_each = data.aws_subnet_ids.public.ids
  id       = each.value
}
data "aws_subnet" "cidr_private" {
  for_each = data.aws_subnet_ids.private.ids
  id       = each.value
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
data "terraform_remote_state" "setup" {
  backend = "s3"

  config = {
    bucket = "${var.remote_state_bucket}"
    key    = "stacks/setup"
    region = "${var.aws_region}"
  }

  workspace = "${terraform.workspace}"
}
data "terraform_remote_state" "iam" {
  backend = "s3"

  config = {
    bucket = "${var.remote_state_bucket}"
    key    = "stacks/iam"
    region = "${var.aws_region}"
  }

  workspace = "${terraform.workspace}"
}
