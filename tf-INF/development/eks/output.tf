output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_ca" {
  value = module.eks.cluster_certificate_authority_data
}

output "cluster_auth_token" {
  value = data.aws_eks_cluster_auth.eks.token
}
output "kubeconfig_filename" {
  value = module.eks.kubeconfig_filename
}

output "auth_cm" {
  value = module.eks.config_map_aws_auth
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

# output "charts_name" {
#   value = list(helm_release.prometheus.chart,
#     helm_release.node_termination_handler.chart,
#     helm_release.goharbor.chart,
#   helm_release.external_dns.chart)
# }
