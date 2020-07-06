provider "kubernetes" {
  host                   = data.aws_eks_cluster.production.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.production.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.production.token
  load_config_file       = false
  version                = "~> 1.9"
}

resource "kubernetes_cluster_role" "admin" {
  metadata {
    name = "admin-role"
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_service_account" "admin" {
  metadata {
    name      = "admin"
    namespace = "kube-system"
  }
  secret {
    name = kubernetes_secret.admin.metadata.0.name
  }
}

resource "kubernetes_secret" "admin" {
  metadata {
    name = "admin"
  }
}

resource "kubernetes_role_binding" "admin" {
  metadata {
    name      = "admin"
    namespace = "kube-system"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "admin"
    namespace = "kube-system"
  }
}

resource "kubernetes_namespace" "bootstrap" {
  metadata {
    labels = {
      stack = local.namespace[0]
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
