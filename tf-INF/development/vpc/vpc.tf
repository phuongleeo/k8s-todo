module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.24.0"
  name    = "${var.project}-${var.environment}-vpc"
  cidr    = "${var.cidr_v4}"

  azs                    = local.availability_zones
  public_subnets         = [for sub_id in range(0, 3) : cidrsubnet(var.cidr_v4, 3, sub_id)]
  private_subnets        = [for sub_id in range(3, 6) : cidrsubnet(var.cidr_v4, 3, sub_id)]
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_vpn_gateway     = false
  enable_dns_hostnames   = true
  enable_dns_support     = true

  # # VPC Endpoint for ECR API
  # enable_ecr_api_endpoint              = true
  # ecr_api_endpoint_private_dns_enabled = true
  # ecr_api_endpoint_security_group_ids  = ["${aws_security_group.default.id}"]

  tags = "${merge(
    local.common_tags,
  map("kubernetes.io/cluster/${local.cluster_name}", "shared"))}"
  vpc_endpoint_tags = {
    Endpoint = "true"
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
