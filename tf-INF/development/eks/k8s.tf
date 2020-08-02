provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks.token
  load_config_file       = false
  version                = "~> 1.9"
}
//namespace
resource "kubernetes_namespace" "bootstrap" {
  metadata {
    labels = {
      stack = local.namespace[0]
      # istio-injection= "enabled" // enable istio sidecar injection
    }

    name = local.namespace[0]
  }
}
resource "kubernetes_namespace" "monitoring" {
  metadata {
    labels = {
      stack = local.namespace[1]
    }

    name = local.namespace[1]
  }
}
//Admin cluster
resource "kubernetes_cluster_role" "cluster_admin" {
  metadata {
    name = "cluster-admin-tf"
    annotations = {
      "rbac.authorization.kubernetes.io/autoupdate" = true
    }
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_service_account" "cluster_admin" {
  metadata {
    name      = "cluster-admin-tf"
    namespace = "kube-system"
  }
  secret {
    name = kubernetes_secret.cluster_admin.metadata.0.name
  }
}

resource "kubernetes_secret" "cluster_admin" {
  metadata {
    name = "cluster-admin-tf"
  }
}

resource "kubernetes_cluster_role_binding" "admin" {
  metadata {
    name = kubernetes_service_account.cluster_admin.metadata.0.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.cluster_admin.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cluster_admin.metadata.0.name
    namespace = " "
  }
}

//This is to create an extra kubernetes clusterrole for developers
resource "kubernetes_cluster_role" "developer" {
  metadata {
    name = "developer"
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["get", "list", "watch"]
  }

  # allow port-forward
  rule {
    api_groups = [""]
    resources  = ["pods/portforward"]
    verbs      = ["get", "list", "create"]
  }

  # allow exec into pod
  rule {
    api_groups = [""]
    resources  = ["pods/exec"]
    verbs      = ["create"]
  }
}
