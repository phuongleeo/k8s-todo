locals {
  namespace = ["bootstrap", "monitoring"]
}

locals {
  char_repository = {
    "stable" = "https://kubernetes-charts.storage.googleapis.com"
    "eks"    = "https://aws.github.io/eks-charts"
    "harbor" = "https://helm.goharbor.io"
    "binami" = "https://charts.bitnami.com/bitnami"
  }
}
