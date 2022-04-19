data "aws_eks_cluster" "eks" {
  name = local.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = local.cluster_name
}
data "aws_iam_policy" "atlantis" {
  name = "AdministratorAccess"
}
