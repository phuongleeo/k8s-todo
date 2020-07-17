output "cert_arn" {
  value = join(",", aws_acm_certificate.eks.*.arn)
}
output "ingress_arn" {
  value = aws_lb.public_ingress.arn
}
output "ingress_dns_name" {
  value = aws_lb.public_ingress.dns_name
}
