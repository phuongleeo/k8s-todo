output "chart_fqdn" {
  value = aws_s3_bucket.chart.bucket_domain_name
}

output "chart_name" {
  value = aws_s3_bucket.chart.id
}

output "chart_arn" {
  value = aws_s3_bucket.chart.arn
}

output "vault_name" {
  value = aws_s3_bucket.wizelineos_global_vault.id
}
