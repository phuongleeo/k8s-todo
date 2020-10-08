provider "aws" {
  allowed_account_ids = [var.aws_account]

  region  = var.aws_region
  version = "~> 2.40"
}

data "aws_region" "current" {
}


provider "kubernetes-alpha" {
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_ca)
  token                  = data.terraform_remote_state.eks.outputs.cluster_auth_token
  version                = "~> 0.2"

  config_path = "/Users/phuongleeo/Documents/NFQ/github-nfq/devops/k8s-todo/tf-INF/development/eks/kubeconfig_starburst-dev"
}

//please include terraform_remote_state eksv2 when initiate k8s deployment resources
provider "kubernetes" {
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_ca)
  token                  = data.terraform_remote_state.eks.outputs.cluster_auth_token
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
