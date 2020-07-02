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
