resource "aws_route53_zone" "eks" {
  name = local.eks_domain
  tags = merge(local.common_tags,
         "Kind","external-dns"
}
//add NS eks into parent zone
resource "aws_route53_record" "ryte_tech" {
  depends_on      = ["aws_route53_zone.eks"]
  allow_overwrite = true
  name            = local.eks_domain
  ttl             = 60
  type            = "NS"
  zone_id         = "${data.aws_route53_zone.zone.zone_id}"

  records = [
    for i in aws_route53_zone.eks.name_servers : i
  ]
}
///end
