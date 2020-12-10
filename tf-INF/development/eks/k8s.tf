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
resource "kubernetes_namespace" "argocd" {
  metadata {
    labels = {
      stack = local.namespace[2]
    }

    name = local.namespace[2]
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

resource "kubernetes_service_account" "harbor" {
  metadata {
    name      = "harbor"
    namespace = kubernetes_namespace.bootstrap.metadata.0.name

    annotations = {
      "eks.amazonaws.com/role-arn"                  = module.harbor_role.this_iam_role_arn
      "rbac.authorization.kubernetes.io/autoupdate" = true
    }
  }
  secret {
    name = kubernetes_secret.harbor.metadata.0.name
  }
}
resource "kubernetes_secret" "harbor" {
  metadata {
    name      = "harbor"
    namespace = kubernetes_namespace.bootstrap.metadata.0.name
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


//image pull secret
resource "aws_ssm_parameter" "quay_registry_username" {
  name        = "quay-registry-username"
  description = "credentials for pulling images"
  type        = "SecureString"
  value       = "to_be_changed"
  overwrite   = true
  tags        = local.common_tags
  lifecycle {
    ignore_changes = [value]
  }
}
resource "aws_ssm_parameter" "quay_registry_password" {
  name        = "quay-registry-password"
  description = "credentials for pulling images"
  type        = "SecureString"
  value       = "to_be_changed"
  overwrite   = true
  tags        = local.common_tags
  lifecycle {
    ignore_changes = [value]
  }
}
resource "aws_ssm_parameter" "github_registry_username" {
  name        = "github-registry-username"
  description = "credentials for pulling images"
  type        = "SecureString"
  overwrite   = true
  value       = "to_be_changed"
  tags        = local.common_tags
  lifecycle {
    ignore_changes = [value]
  }
}
resource "aws_ssm_parameter" "github_registry_password" {
  name        = "github-registry-password"
  description = "credentials for pulling images"
  type        = "SecureString"
  overwrite   = true
  value       = "to_be_changed"
  tags        = local.common_tags
  lifecycle {
    ignore_changes = [value]
  }
}
//this equivalent to the kubectl command
//$ kubectl create secret docker-registry docker-cfg --docker-server=${registry_server} --docker-username=${registry_username} --docker-password=${registry_password}
resource "kubernetes_secret" "quay_registry_credentials" {
  metadata {
    name = "quay-docker-cfg"
  }

  data = {
    ".dockerconfigjson" = <<DOCKER
{
  "auths": {
    "${local.quay_registry_server}": {
      "auth": "${base64encode("${aws_ssm_parameter.quay_registry_username.value}:${aws_ssm_parameter.quay_registry_password.value}")}"
    }
  }
}
DOCKER
  }

  type = "kubernetes.io/dockerconfigjson"
}

resource "kubernetes_secret" "github_registry_credentials" {
  metadata {
    name = "github-docker-cfg"
  }

  data = {
    ".dockerconfigjson" = <<DOCKER
{
  "auths": {
    "${local.github_registry_server}": {
      "auth": "${base64encode("${aws_ssm_parameter.github_registry_username.value}:${aws_ssm_parameter.github_registry_password.value}")}"
    }
  }
}
DOCKER
  }

  type = "kubernetes.io/dockerconfigjson"
}
