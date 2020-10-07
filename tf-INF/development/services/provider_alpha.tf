provider "kubernetes-alpha" {
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_ca)
  token                  = data.terraform_remote_state.eks.outputs.cluster_auth_token
  version                = "~> 0.2"

  config_path = "/Users/phuongleeo/Documents/NFQ/github-nfq/devops/k8s-todo/tf-INF/development/eks/kubeconfig_starburst-dev"
}
