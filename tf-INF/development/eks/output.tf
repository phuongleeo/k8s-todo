output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_ca" {
  value = module.eks.cluster_certificate_authority_data
}

output "kubeconfig_filename" {
  value = module.eks.kubeconfig_filename
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}
output "worker_secgroup_id" {
  value = aws_security_group.all_worker_mgmt.id
}
output "image_pull_secret" {
  value = map(
    local.quay_registry_server, kubernetes_secret.quay_registry_credentials.metadata[0].name,
  local.github_registry_server, kubernetes_secret.github_registry_credentials.metadata[0].name)
}

output "jx_requirements" {
  value = module.jx.jx_requirements
}

output "vault_user_id" {
  value       = module.jx.vault_user_id
  description = "The Vault IAM user id"
}

output "vault_user_secret" {
  value       = module.jx.vault_user_secret
  description = "The Vault IAM user secret"
}
