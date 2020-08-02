data "template_file" "pod_restrict" {
  template = file("userdata/pod_restrict.sh")
}
resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = data.aws_vpc.development.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      var.cidr_v4,
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = data.aws_vpc.development.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      var.cidr_v4
    ]
  }
}
data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  cluster_name                    = local.cluster_name
  cluster_version                 = "1.17"
  subnets                         = data.aws_subnet_ids.private.ids
  vpc_id                          = data.aws_vpc.development.id
  write_kubeconfig                = true
  config_output_path              = "kubeconfig_${local.cluster_name}"
  map_accounts                    = [var.aws_account]
  enable_irsa                     = true
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true // terraform plan -target=module.eks_services.aws_eks_cluster.this -out plan
  # cluster_endpoint_public_access_cidrs = local.whitelist_ips
  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]

  worker_groups = [
    # {
    #   instance_type                 = "m5a.large"
    #   asg_max_size                  = 2
    #   asg_desired_capacity          = 1
    #   key_name                      = var.ssh_key_name
    #   kubelet_extra_args            = "--node-labels=spot=false"
    #   suspended_processes           = ["AZRebalance"]
    #   additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    #   root_volume_size              = "20"
    #
    #   tags = concat(
    #     list(map(
    #       "propagate_at_launch", true,
    #       "key", "Group",
    #     "value", "${var.environment}"))
    #   )
    # }
  ]
  worker_groups_launch_template = [
    {
      name                    = "spot-1"
      spot_price              = "0.2"
      override_instance_types = ["t3a.medium", "t3a.large"]
      root_volume_size        = "20"
      asg_max_size            = 4
      asg_desired_capacity    = 2
      kubelet_extra_args      = "--node-labels=node.kubernetes.io/lifecycle=spot"
      # additional_userdata     = data.template_file.pod_restrict.rendered
    }

  ]
  tags = merge(local.common_tags,
    map(
      "k8s.io/cluster-autoscaler/enabled", true,
      "k8s.io/cluster-autoscaler/${local.cluster_name}", true
  ))
}

resource "null_resource" "install_istio" {
  depends_on = [
    module.eks
  ]

  triggers = {
    cluster_endpoint = module.eks.cluster_endpoint
  }

  provisioner "local-exec" {
    command     = "files/install-istio.sh"
    interpreter = ["/bin/bash"]
    environment = {
      KUBECONFIG      = pathexpand("${path.cwd}/kubeconfig_${local.cluster_name}")
      BINARY_DIR      = pathexpand("${path.cwd}/files/istio-1.6.5")
      ISTIO_VERSION   = "1.6.5"
      ISTIO_OVERWRITE = pathexpand("${path.cwd}/files/istio-operator.yaml")
      CERT_ARN        = data.terraform_remote_state.setup.outputs.cert_arn
    }
  }
}

//update only if subnets was created before
# resource "aws_subnet" "subnet_public" {
#   for_each   = data.aws_subnet.cidr_public
#   vpc_id     = data.aws_vpc.development.id
#   cidr_block = each.value.cidr_block
#   tags = {
#     "kubernetes.io/role/elb"                      = 1
#     "kubernetes.io/cluster/${local.cluster_name}" = "shared"
#   }
# }
# resource "aws_subnet" "subnet_private" {
#   for_each   = data.aws_subnet.cidr_private
#   vpc_id     = data.aws_vpc.development.id
#   cidr_block = each.value.cidr_block
#   tags = {
#     "kubernetes.io/role/internal-elb"             = 1
#     "kubernetes.io/cluster/${local.cluster_name}" = "shared"
#   }
# }
