provider "kubernetes-alpha" {
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_ca)
  token                  = data.aws_eks_cluster_auth.eks.token
  version                = "~> 0.2"
}
