//please include terraform_remote_state eksv2 when initiate k8s deployment resources
provider "kubernetes" {
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_ca)
  token                  = data.terraform_remote_state_auth.eks.outputs.cluster_auth_token
  load_config_file       = false
  version                = "~> 1.9"
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_ca)
    token                  = data.terraform_remote_state.eks.outputs.cluster_auth_token
    load_config_file       = false
  }
  version = "~> 1.0"
}
