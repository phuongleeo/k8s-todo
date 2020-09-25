output "cert_arn" {
  value = join(",", aws_acm_certificate.eks.*.arn)
}
