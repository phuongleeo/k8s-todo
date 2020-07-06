output "admin_sa" {
  value = "${kubernetes_service_account.admin.metadata}"
}

output "auth_cm" {
  value = "${module.eks_production.config_map_aws_auth}"
}

output "oidc_provider_arn" {
  value = "${module.eks_production.oidc_provider_arn}"
}

output "cluster_oidc_issuer_url" {
  value = "${module.eks_production.cluster_oidc_issuer_url}"
}
