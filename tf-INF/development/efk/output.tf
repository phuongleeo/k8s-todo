output "cluster_endpoint" {
  value = module.eks_production.cluster_endpoint
}

output "cluster_ca" {
  value = module.eks_production.cluster_certificate_authority_data
}

output "cluster_auth_token" {
  value = data.aws_eks_cluster_auth.production.token
}

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

output "charts_name" {
  value = list(helm_release.prometheus.chart,
    helm_release.node_termination_handler.chart,
    helm_release.goharbor.chart,
  helm_release.external_dns.chart)
}
