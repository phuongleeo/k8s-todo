data "aws_vpc" "development" {
  cidr_block = var.cidr_v4
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.development.id
  filter {
    name   = "tag:Name"
    values = ["development-subnet-public"]
  }
}
