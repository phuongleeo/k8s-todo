terraform {
  backend "s3" {
    key = "stacks/eks"
  }
}

data "aws_vpc" "development" {
  cidr_block = "10.51.0.0/21"
}
data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.development.id
  filter {
    name   = "tag:Name"
    values = ["development-subnet-private"]
  }
}
