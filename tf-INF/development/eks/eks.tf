data "template_file" "pod_restrict" {
  template = file("userdata/pod_restrict.sh")
}
resource "aws_security_group" "worker_group_mgmt_one" {
  description = "default secgroup for worker nodes"
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

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
  description = "default secgroup for worker nodes"
  name_prefix = "all_worker_management"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      var.cidr_v4
    ]
  }
  ingress {
    description = "permit EFS filesystem"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"

    cidr_blocks = [
      var.cidr_v4
    ]
  }
}

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "16.0.0"
  cluster_name                    = local.cluster_name
  cluster_version                 = "1.21"
  subnets                         = data.terraform_remote_state.vpc.outputs.subnet_private
  vpc_id                          = data.terraform_remote_state.vpc.outputs.vpc_id
  write_kubeconfig                = true
  config_output_path              = pathexpand("~/.kube/kubeconfig_${local.cluster_name}")
  map_accounts                    = [var.aws_account]
  enable_irsa                     = true
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  # cluster_endpoint_public_access_cidrs = local.whitelist_ips
  worker_additional_security_group_ids       = [aws_security_group.all_worker_mgmt.id]
  workers_additional_policies                = [aws_iam_policy.workers_ecr.arn]
  kubeconfig_aws_authenticator_env_variables = { AWS_PROFILE = "default" }

  worker_groups = [
  ]
  worker_groups_launch_template = [
    {
      //https://aws.amazon.com/blogs/opensource/announcing-the-general-availability-of-bottlerocket-an-open-source-linux-distribution-purpose-built-to-run-containers/
      name                          = "%{if local.spot_instances}spot-1%{else}on-demand%{endif}"
      spot_price                    = "%{if local.spot_instances}local.bid_price%{endif}"
      override_instance_types       = ["t3a.medium", "t3a.large"]
      root_volume_size              = "20"
      asg_max_size                  = 4
      asg_min_size                  = 0
      asg_desired_capacity          = 2
      key_name                      = data.terraform_remote_state.key_pair.outputs.key_name
      kubelet_extra_args            = "%{if local.spot_instances}--node-labels=node.kubernetes.io/lifecycle=spot%{else}--node-labels=node.kubernetes.io/lifecycle=normal%{endif}"
      additional_userdata           = data.template_file.pod_restrict.rendered
      suspended_processes           = ["AZRebalance"]
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      //https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/enable-docker-bridge-network.md
      bootstrap_extra_args = "--enable-docker-bridge true"
    },
    {
      name                                     = "on-demand-vault"
      override_instance_types                  = ["t3a.medium", "t3a.large"]
      root_volume_size                         = "20"
      on_demand_base_capacity                  = 3
      on_demand_percentage_above_base_capacity = 100
      asg_max_size                             = 3
      asg_min_size                             = 1
      asg_desired_capacity                     = 3
      key_name                                 = data.terraform_remote_state.key_pair.outputs.key_name
      kubelet_extra_args                       = "--node-labels=node.kubernetes.io/lifecycle=normal,application=vault --register-with-taints=application=vault:NoExecute"
      additional_userdata                      = data.template_file.pod_restrict.rendered
      suspended_processes                      = ["AZRebalance"]
      additional_security_group_ids            = []
      //https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/enable-docker-bridge-network.md
      bootstrap_extra_args = "--enable-docker-bridge true"
    },
  ]
  tags = merge(local.common_tags,
    map(
      "k8s.io/cluster-autoscaler/enabled", true,
      "k8s.io/cluster-autoscaler/${local.cluster_name}", true
  ))
}
//ECR policy
data "aws_iam_policy_document" "workers_ecr" {
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetAuthorizationToken",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]

    resources = [
      "*",
    ]
  }
}
resource "aws_iam_policy" "workers_ecr" {
  name   = "${var.environment}-workers-ecr"
  policy = data.aws_iam_policy_document.workers_ecr.json
}

resource "local_file" "istio_operator" {
  content = templatefile("files/istio-operator.yaml.tmpl", {
  CERT_ARN = data.terraform_remote_state.setup.outputs.cert_arn })
  filename = "files/istio-operator.yaml"
}

resource "null_resource" "install_istio" {
  count = local.enable_ingress_istio ? 1 : 0
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
      KUBECONFIG      = pathexpand("~/.kube/kubeconfig_${local.cluster_name}")
      ISTIO_VERSION   = "1.6.9"
      ISTIO_OVERWRITE = pathexpand("${path.cwd}/${local_file.istio_operator.filename}")
      CERT_ARN        = data.terraform_remote_state.setup.outputs.cert_arn
    }
  }
}
