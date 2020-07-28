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
    name = "cluster-admin-tf"
    # namespace = "kube-system"
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

# //external dns
# resource "kubernetes_cluster_role" "external_dns" {
#   metadata {
#     name = "external-dns-role"
#     annotations = {
#       "rbac.authorization.kubernetes.io/autoupdate" = true
#     }
#   }
#
#   rule {
#     api_groups = ["*"]
#     resources  = ["services", "endpoints", "pods"]
#     verbs      = ["get", "watch", "list"]
#   }
#   rule {
#     api_groups = ["extensions"]
#     resources  = ["ingresses"]
#     verbs      = ["get", "watch", "list"]
#   }
#   rule {
#     api_groups = ["*"]
#     resources  = ["nodes"]
#     verbs      = ["watch", "list"]
#   }
# }
#
# resource "kubernetes_service_account" "external_dns" {
#   metadata {
#     name = "external-dns"
#     namespace = kubernetes_namespace.bootstrap.metadata.0.name
#     annotations = {
#       "eks.amazonaws.com/role-arn" = module.external_dns_role.arn
#     }
#   }
#   secret {
#     name = kubernetes_secret.external_dns.metadata.0.name
#   }
# }
#
# resource "kubernetes_secret" "external_dns" {
#   metadata {
#     name = "external-dns"
#   }
# }
# resource "kubernetes_cluster_role_binding" "external_dns" {
#   metadata {
#     name = "external-dns"
#     # namespace = kubernetes_namespace.bootstrap.metadata.0.name
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = kubernetes_cluster_role.external_dns.metadata.0.name
#   }
#   subject {
#     kind      = "ServiceAccount"
#     name      = kubernetes_service_account.external_dns.metadata.0.name
#     namespace = " "
#   }
# }
#
# //gohabor
# resource "kubernetes_cluster_role" "harbor" {
#   metadata {
#     name = "harbor-role"
#     annotations = {
#       "rbac.authorization.kubernetes.io/autoupdate" = true
#     }
#   }
#
#   rule {
#     api_groups = ["*"]
#     resources  = ["services", "endpoints", "pods"]
#     verbs      = ["get", "watch", "list"]
#   }
#   rule {
#     api_groups = ["extensions"]
#     resources  = ["ingresses"]
#     verbs      = ["get", "watch", "list"]
#   }
#   rule {
#     api_groups = ["*"]
#     resources  = ["nodes"]
#     verbs      = ["watch", "list"]
#   }
# }
#
# resource "kubernetes_service_account" "harbor" {
#   metadata {
#     name = "harbor"
#     # namespace = kubernetes_namespace.bootstrap.metadata.0.name
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.harbor.arn
#     }
#   }
#   secret {
#     name = kubernetes_secret.harbor.metadata.0.name
#   }
# }
#
# resource "kubernetes_secret" "harbor" {
#   metadata {
#     name = "harbor"
#   }
# }
# resource "kubernetes_cluster_role_binding" "harbor" {
#   metadata {
#     name = "harbor"
#     # namespace = kubernetes_namespace.bootstrap.metadata.0.name
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = kubernetes_cluster_role.harbor.metadata.0.name
#   }
#   subject {
#     kind      = "ServiceAccount"
#     name      = kubernetes_service_account.harbor.metadata.0.name
#     namespace = " "
#   }
# }
