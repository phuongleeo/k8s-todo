provider "kubernetes" {
  host                   = data.aws_eks_cluster.production.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.production.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.production.token
  load_config_file       = false
  version                = "~> 1.9"
}
//namespace
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
//Admin cluster
resource "kubernetes_cluster_role" "cluster_admin" {
  metadata {
    name = "cluster-admin"
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_service_account" "cluster_admin" {
  metadata {
    name      = "cluster-admin"
    namespace = "kube-system"
  }
  secret {
    name = kubernetes_secret.cluster_admin.metadata.0.name
  }
}

resource "kubernetes_secret" "cluster_admin" {
  metadata {
    name = "cluster_admin"
  }
}

resource "kubernetes_role_binding" "admin" {
  metadata {
    name      = "cluster-admin"
    namespace = "kube-system"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.cluster_admin.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cluster_admin.metadata.0.name
    namespace = "kube-system"
  }
}

//external dns
resource "kubernetes_cluster_role" "external_dns" {
  metadata {
    name = "external-dns-role"
  }

  rule {
    api_groups = ["*"]
    resources  = ["services","endpoints","pods"]
    verbs      = ["get","watch","list"]
  }
  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses"]
    verbs      = ["get","watch","list"]
  }
  rule {
    api_groups = ["*"]
    resources  = ["nodes"]
    verbs      = ["watch","list"]
  }
}

resource "kubernetes_service_account" "external_dns" {
  metadata {
    name      = "external-dns"
    namespace = kubernetes_namespace.bootstrap.metadata.0.name
    annotations = map("eks.amazonaws.com/role-arn",aws_iam_role.external_dns.arn)
  }
  secret {
    name = kubernetes_secret.external_dns.metadata.0.name
  }
}

resource "kubernetes_secret" "external_dns" {
  metadata {
    name = "external-dns"
  }
}
resource "kubernetes_role_binding" "external_dns" {
  metadata {
    name      = "external-dns"
    namespace = kubernetes_namespace.bootstrap.metadata.0.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.external_dns.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.external_dns.metadata.0.name
    namespace = "kube-system"
  }
}
