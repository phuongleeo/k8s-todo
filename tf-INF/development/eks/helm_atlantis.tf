resource "helm_release" "atlantis" {
  count = local.enable_atlantis ? 1 : 0
  depends_on = [
    module.eks,
  ]
  name       = "atlantis"
  repository = "https://runatlantis.github.io/helm-charts"
  chart      = "atlantis"
  version    = "3.15.1"
  namespace  = kubernetes_namespace.bootstrap.metadata.0.name
  lint       = false
  wait       = true
  set {
    name  = "orgWhitelist"
    value = var.github_url
  }
  set {
    name  = "github.user"
    value = "Atlantis"
  }
  set_sensitive {
    name  = "github.token"
    value = aws_ssm_parameter.atlantis_gh_token.value
  }
  set_sensitive {
    name  = "github.secret"
    value = aws_ssm_parameter.atlantis_gh_webhook_secret.value
  }
  set {
    name  = "repoConfig"
    value = <<EOF
    repos:
    - id: /.*/
      branch: /.*/
      allow_custom_workflows: true
      allowed_overrides:
        - apply_requirements
        - workflow
      apply_requirements:
        - approved
        - mergeable
      allowed_workflows:
        - development
    workflows:
        development:
            plan:
                steps:
                    - init:
                        extra_args:
                          - "-backend-config='region=${var.aws_region}'"
                          - "-backend-config='bucket=${var.remote_state_bucket}'"
                    - plan
            apply:
                steps:
                    - apply
EOF
  }
  set {
    name  = "defaultTFVersion"
    value = "0.14.11"
  }
  set {
    name  = "enableDiffMarkdownFormat"
    value = true
  }
  set {
    name  = "ingress.ingressClassName"
    value = "nginx"
  }
  set {
    name  = "ingress.annotations.external-dns\\.alpha\\.kubernetes\\.io"
    value = "enable"
  }
  # Whitelist Github source addresses: https://api.github.com/meta
  set {
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/whitelist-source-range"
    value = local.github_source_address
    type  = "string"
  }
  set {
    name  = "ingress.host"
    value = "atlantis.${var.domain_name}"
  }
  set {
    name  = "resources.limits.cpu"
    value = "500m"
  }
  set {
    name  = "dataStorage"
    value = "10Gi"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_assumable_role_atlantis.this_iam_role_arn
  }
}
