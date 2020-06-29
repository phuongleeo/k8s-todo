resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}
data "aws_eks_cluster" "production" {
  name = module.eks_production.cluster_id
}

data "aws_eks_cluster_auth" "production" {
  name = module.eks_production.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.production.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.production.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.production.token
  load_config_file       = false
  version                = "~> 1.9"
}

module "eks_production" {
  source                = "terraform-aws-modules/eks/aws"
  version               = "~> 8.2.0"
  cluster_name          = local.cluster_name
  cluster_version       = "1.14"
  subnets               = data.terraform_remote_state.vpc.outputs.subnet_private
  vpc_id                = data.terraform_remote_state.vpc.outputs.vpc_id
  write_kubeconfig = true
  map_accounts                         = [var.aws_account]
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = true // terraform plan -target=module.eks_services.aws_eks_cluster.this -out plan
  # cluster_endpoint_public_access_cidrs = local.whitelist_ips
  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  worker_groups = [
    {
      ami_id = data.terraform_remote_state.ami.outputs.eks_optimized
      instance_type                 = "m5a.4xlarge"
      asg_max_size                  = 2
      asg_desired_capacity          = 1
      key_name                      = data.terraform_remote_state.key_pair.outputs.key_name
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]

      tags = concat(
        list(map(
          "propagate_at_launch",true,
          "key", "Group",
          "value","${var.environment}"))
        )
    },
  ]
  tags                                 = local.common_tags
}
