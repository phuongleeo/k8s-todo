provider "kubernetes-alpha" {
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_ca)
  token                  = data.terraform_remote_state.eks.outputs.cluster_auth_token
  version                = "~> 0.2"
}
