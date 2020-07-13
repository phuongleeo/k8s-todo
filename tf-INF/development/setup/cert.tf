resource "aws_acm_certificate" "eks" {
  count                     = local.create_eks_cert ? 1 : 0
  domain_name               = local.eks_domain
  subject_alternative_names = ["*.${local.eks_domain}"]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  count   = local.create_eks_cert ? 1 : 0
  name    = aws_acm_certificate.eks[count.index].domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.eks[count.index].domain_validation_options[0].resource_record_type
  zone_id = data.terraform_remote_state.route53.outputs.eks_zone_id
  records = [aws_acm_certificate.eks[count.index].domain_validation_options[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  count                   = local.create_eks_cert ? 1 : 0
  certificate_arn         = aws_acm_certificate.eks[count.index].arn
  validation_record_fqdns = [aws_route53_record.cert_validation[count.index].fqdn]
}
