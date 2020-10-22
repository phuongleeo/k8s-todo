//please include terraform_remote_state eks when initiate k8s deployment resources
provider "kubernetes" {
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_ca)
  token                  = data.aws_eks_cluster_auth.eks.token
  load_config_file       = false
  version                = "~> 1.13"
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_ca)
    token                  = data.aws_eks_cluster_auth.eks.token
    load_config_file       = false
  }
  version = "~> 1.3"
}

data "aws_eks_cluster_auth" "eks" {
  name = local.cluster_name
}
